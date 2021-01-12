defmodule ShlinkedinWeb.GroupLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Groups
  alias Shlinkedin.Groups.Group
  alias Shlinkedin.MediaUpload

  @impl true
  def mount(socket) do
    {:ok,
     allow_upload(socket, :media,
       accept: ~w(.png .jpeg .jpg .gif),
       max_entries: 1,
       external: &MediaUpload.presign_media_entry/2
     )}
  end

  @impl true
  def update(%{group: group} = assigns, socket) do
    changeset = Groups.change_group(group)

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
  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset =
      socket.assigns.group
      |> Groups.change_group(group_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"group" => group_params}, socket) do
    save_group(socket, socket.assigns.action, group_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  defp put_photo_urls(socket, attrs) do
    {completed, []} = uploaded_entries(socket, :media)

    urls =
      for entry <- completed do
        # Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}") # local path
        Path.join(MediaUpload.s3_host(), MediaUpload.s3_key(entry))
      end

    Map.put(attrs, "cover_photo_url", urls |> Enum.at(0))
  end

  def consume_photos(socket, %Group{} = group) do
    consume_uploaded_entries(socket, :media, fn _meta, _entry -> :ok end)

    {:ok, group}
  end

  defp save_group(
         %{assigns: %{profile: profile, group: group}} = socket,
         :edit_group,
         group_params
       ) do
    group_params = put_photo_urls(socket, group_params)

    case Groups.update_group(
           profile,
           group,
           group_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Group updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_group(%{assigns: %{profile: profile, group: group}} = socket, :new, group_params) do
    group_params = put_photo_urls(socket, group_params)

    case Groups.create_group(profile, group, group_params, &consume_photos(socket, &1)) do
      {:ok, group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Group created successfully")
         |> push_redirect(to: Routes.group_show_path(@socket, :show, group.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
