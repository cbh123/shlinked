defmodule ShlinkedinWeb.StoryLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Story

  @impl true
  def mount(socket) do
    {:ok,
     allow_upload(socket, :media,
       accept: ~w(.png .jpeg .jpg .gif .mp4 .mov),
       max_entries: 1,
       external: &presign_entry/2
     )}
  end

  @impl true
  def update(%{story: story} = assigns, socket) do
    changeset = Timeline.change_story(story)

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
  def handle_event("validate", params, socket) do
    changeset =
      socket.assigns.story
      |> Timeline.change_story(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"story" => story_params}, socket) do
    save_story(socket, socket.assigns.action, story_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  defp put_photo_urls(socket, %Story{} = story) do
    {completed, []} = uploaded_entries(socket, :media)

    urls =
      for entry <- completed do
        # Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}") # local path
        Path.join(s3_host(), s3_key(entry))
      end

    %Story{story | media_url: urls |> Enum.at(0)}
  end

  def consume_photos(socket, %Story{} = story) do
    consume_uploaded_entries(socket, :media, fn _meta, _entry -> :ok end)

    {:ok, story}
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp save_story(socket, :edit_story, story_params) do
    story = put_photo_urls(socket, socket.assigns.story)

    case Timeline.update_story(
           socket.assigns.profile,
           story,
           story_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, _story} ->
        {:noreply,
         socket
         |> put_flash(:info, "story updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_story(%{assigns: %{profile: profile}} = socket, :new_story, story_params) do
    story = put_photo_urls(socket, %Story{})

    case Timeline.create_story(
           profile,
           story,
           story_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, _story} ->
        {:noreply,
         socket
         |> put_flash(:info, "Story created successfully")
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
        max_file_size: uploads.media.max_file_size,
        expires_in: :timer.minutes(2)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end
end
