defmodule ShlinkedinWeb.PostLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline
  alias Shlinkedin.Tagging
  alias Shlinkedin.Timeline.Post

  @impl true
  def mount(socket) do
    assigns = [
      gif_url: nil,
      gif_error: nil,
      tags: [],
      search_results: [],
      current_focus: -1,
      tagging_mode: false,
      query: ""
    ]

    socket = assign(socket, assigns)

    {:ok,
     allow_upload(socket, :photo,
       accept: ~w(.png .jpeg .jpg .gif .mp4 .mov),
       max_entries: 1,
       external: &presign_entry/2
     )}
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Timeline.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def update(%{uploads: uploads}, socket) do
    socket = assign(socket, :uploads, uploads)
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    body = post_params["body"]

    changeset =
      socket.assigns.post
      |> Timeline.change_post(post_params)
      |> Map.put(:action, :validate)

    new_tagging_mode = Tagging.check_tagging_mode(body, socket.assigns.tagging_mode)

    {:noreply,
     assign(socket,
       changeset: changeset,
       tagging_mode: new_tagging_mode,
       query: Tagging.add_to_query(new_tagging_mode, body),
       search_results: Tagging.get_search_results(new_tagging_mode, socket.assigns.query)
     )}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  def handle_event("cancel-gif", _, socket) do
    {:noreply, assign(socket, :gif_url, nil)}
  end

  def handle_event("add-gif", _params, socket) do
    case socket.assigns.changeset.changes[:body] do
      nil ->
        {:noreply, assign(socket, gif_error: "Pls enter text first!")}

      body ->
        gif_url = Timeline.get_gif_from_text(body)
        {:noreply, socket |> assign(gif_url: gif_url, gif_error: nil)}
    end
  end

  def handle_event("pick", %{"name" => username}, socket) do
    body = socket.assigns.changeset.changes.body
    sliced_body = String.replace(body, String.split(body, "@") |> List.last(), "")
    new_body = sliced_body <> username <> " "

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:body, new_body)

    {:noreply,
     assign(socket,
       changeset: changeset,
       search_results: [],
       tags: socket.assigns.tags ++ [username]
     )}
  end

  def handle_event("remove-tag", %{"name" => username}, %{assigns: %{tags: tags}} = socket) do
    current_body = socket.assigns.changeset.changes.body

    new_body = String.replace(current_body, "@#{username}", "")

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:body, new_body)

    socket = assign(socket, tags: List.delete(tags, username), changeset: changeset)
    {:noreply, socket}
  end

  defp put_photo_urls(socket, %Post{} = post) do
    {completed, []} = uploaded_entries(socket, :photo)

    urls =
      for entry <- completed do
        # Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}") # local path
        Path.join(s3_host(), s3_key(entry))
      end

    %Post{post | photo_urls: urls}
  end

  def consume_photos(socket, %Post{} = post) do
    consume_uploaded_entries(socket, :photo, fn _meta, _entry -> :ok end)

    {:ok, post}
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp save_post(socket, :edit, post_params) do
    post_params = Map.put(post_params, "profile_tags", socket.assigns.tags)

    post = put_photo_urls(socket, socket.assigns.post)
    post = %Post{post | gif_url: socket.assigns.gif_url}

    case Timeline.update_post(
           socket.assigns.profile,
           post,
           post_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(%{assigns: %{profile: profile}} = socket, :new, post_params) do
    post_params = Map.put(post_params, "profile_tags", socket.assigns.tags)
    post = put_photo_urls(socket, %Post{})
    post = %Post{post | gif_url: socket.assigns.gif_url}

    case Timeline.create_post(
           profile,
           post_params,
           post,
           &consume_photos(socket, &1)
         ) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @bucket "shlinked"
  defp s3_host, do: "//#{@bucket}.s3.amazonaws.com"
  defp s3_key(entry), do: "#{entry.uuid}.#{ext(entry)}"

  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads
    key = s3_key(entry)

    config = %{
      scheme: "https://",
      host: "s3.amazonaws.com",
      region: "us-east-1",
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      Shlinkedin.SimpleS3Upload.sign_form_upload(config, @bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads.photo.max_file_size,
        expires_in: :timer.minutes(2)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end
end
