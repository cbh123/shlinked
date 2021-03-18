defmodule ShlinkedinWeb.PostLive.Generator do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Tagging
  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline.Generators
  alias Shlinkedin.MediaUpload

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(body: "", gif_url: nil, page_title: "ShlinkedIn Content Generator")}
  end

  def handle_event("adversity", _, socket) do
    {:noreply, assign(socket, body: Generators.adversity())}
  end

  def handle_event("job", _, socket) do
    {:noreply, assign(socket, body: Generators.job())}
  end

  def handle_event("challenge", _, socket) do
    {:noreply, assign(socket, body: Generators.business_challenge())}
  end

  def handle_event("strange", _, socket) do
    {:noreply, assign(socket, body: Generators.strange_observation())}
  end

  def handle_event("guilt", _, socket) do
    {:noreply, assign(socket, body: Generators.guilt_trip())}
  end

  def handle_event("nft", _params, socket) do
    gif_url = Timeline.get_gif_from_text("nft")

    {:noreply,
     socket
     |> assign(gif_url: gif_url, body: Generators.nft())}
  end

  def handle_event("hashtags", _, socket) do
    IO.inspect(socket.assigns.body, label: "")
    socket = assign(socket, body: socket.assigns.body <> Generators.hashtags())
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    body = post_params["body"]

    changeset =
      socket.assigns.post
      |> Timeline.change_post(post_params)
      |> template_changeset()
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

  def handle_event("adversity", _, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(%{body: Generators.adversity(), generator_type: "adversity"})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, generator_type: "adversity lesson")}
  end

  def handle_event("job", _, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(%{body: Generators.job()})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, generator_type: "job update")}
  end

  def handle_event("challenge", _, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(%{body: Generators.business_challenge()})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, generator_type: "business challenge")}
  end

  def handle_event("strange", _, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(%{body: Generators.strange_observation()})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, generator_type: "strange observation")}
  end

  def handle_event("guilt", _, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(%{body: Generators.guilt_trip()})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, generator_type: "guilt trip")}
  end

  def handle_event("nft", _params, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(%{body: Generators.nft()})
      |> Map.put(:action, :validate)

    gif_url = Timeline.get_gif_from_text("nft")

    {:noreply,
     socket
     |> assign(gif_url: gif_url, gif_error: nil, generator_type: "nft", changeset: changeset)}
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
        Path.join(MediaUpload.s3_host(), MediaUpload.s3_key(entry))
      end

    %Post{post | photo_urls: urls}
  end

  def consume_photos(socket, %Post{} = post) do
    consume_uploaded_entries(socket, :photo, fn _meta, _entry -> :ok end)

    {:ok, post}
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

  defp save_post(%{assigns: %{profile: profile, post: post}} = socket, :new, post_params) do
    post = put_photo_urls(socket, post)
    post = %Post{post | gif_url: socket.assigns.gif_url}

    post_params =
      post_params
      |> Map.put("profile_tags", socket.assigns.tags)
      |> Map.put("generator_type", socket.assigns.generator_type)

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

  defp template_changeset(changeset) do
    case Ecto.Changeset.fetch_change(changeset, :template) do
      :error ->
        changeset

      {:ok, title} ->
        body = Timeline.get_template_by_title_return_body(title)
        changeset |> Ecto.Changeset.put_change(:body, body)
    end
  end
end
