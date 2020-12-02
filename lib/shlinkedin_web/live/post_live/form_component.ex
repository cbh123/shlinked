defmodule ShlinkedinWeb.PostLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline.Profile

  @impl true
  def mount(socket) do
    {:ok, allow_upload(socket, :photo, accept: ~w(.png .jpeg .jpg), max_entries: 1)}
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
  def handle_event("validate", params, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(params["post"])
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  # defp put_photo_urls(socket, %Post{} = post) do
  #   {completed, []} = uploaded_entries(socket, :photo)

  #   url =
  #     for entry <- completed do
  #       Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}")
  #     end

  #   %Post{post | photo_url: url}
  # end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp save_post(socket, :edit, post_params) do
    # post = put_photo_urls(socket(socket.assigns.post))

    case Timeline.update_post(
           socket.assigns.profile,
           socket.assigns.post,
           post_params
         ) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, message} ->
        {:noreply,
         socket
         |> put_flash(:error, message)
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end

  defp save_post(%{assigns: %{profile: profile}} = socket, :new, post_params) do
    # post = put_photo_urls(socket, %Profile{})

    case Timeline.create_post(profile, post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
