defmodule ShlinkedinWeb.StoryLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline.Story
  alias Shlinkedin.Timeline
  alias Shlinkedin.MediaUpload

  @impl true
  def mount(socket) do
    {:ok,
     allow_upload(socket, :media,
       accept: ~w(.png .jpeg .jpg .gif .mp4 .mov),
       max_entries: 1,
       external: &MediaUpload.presign_media_entry/2
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

  defp put_photo_urls(socket, %Shlinkedin.Timeline.Story{} = story) do
    {completed, []} = uploaded_entries(socket, :media)

    urls =
      for entry <- completed do
        # Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}") # local path
        Path.join(MediaUpload.s3_host(), MediaUpload.s3_key(entry))
      end

    %Story{story | media_url: urls |> Enum.at(0)}
  end

  def consume_photos(socket, %Story{} = story) do
    consume_uploaded_entries(socket, :media, fn _meta, _entry -> :ok end)

    {:ok, story}
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
end
