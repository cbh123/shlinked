defmodule ShlinkedinWeb.AdminLive.NotificationFormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Notification

  @impl true
  def update(%{notification: notification} = assigns, socket) do
    changeset = Profiles.change_notification(notification)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"notification" => notification_params}, socket) do
    changeset =
      socket.assigns.notification
      |> Profiles.change_notification(notification_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"notification" => notification_params}, socket) do
    save_notification(socket, socket.assigns.action, notification_params)
  end

  defp save_notification(
         socket,
         :new_email,
         %{"notify_all" => notify_all, "action" => subject, "body" => body}
       ) do
    profile = Profiles.get_profile_by_profile_id_preload_user(socket.assigns.profile.id)
    Profiles.admin_email_all(subject, body, notify_all, profile)

    {:noreply,
     socket
     |> put_flash(:info, "Email successful")
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp save_notification(
         socket,
         :new_notification,
         %{"notify_all" => notify_all} = notification_params
       ) do
    case Profiles.admin_create_notification(
           %Notification{
             from_profile_id: 3,
             type: "admin_message",
             to_profile_id: socket.assigns.profile.id
           },
           notification_params,
           notify_all: notify_all
         ) do
      {:ok, _notification} ->
        {:noreply,
         socket
         |> put_flash(:info, "Notification successful")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
