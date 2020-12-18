defmodule ShlinkedinWeb.NotificationLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  @impl true
  def mount(_params, session, socket) do
    # KNOWN BUG: RIGHT WHEN YOU CREATE AN ACCOUNT, THIS BUTTON DOESN"T WORK! PROBLABLY NOT LOADED INTO SOCKET!
    socket = is_user(session, socket)

    notifications = Profiles.list_notifications(socket.assigns.profile.id)

    {:ok,
     socket
     |> assign(
       notifications: notifications,
       unread_count: Profiles.get_unread_notification_count(socket.assigns.profile)
     ), temporary_assigns: [notifications: []]}
  end

  @impl true
  def handle_event("notification-click", %{"id" => id, "slug" => slug}, socket) do
    Profiles.change_notification_to_read(id |> String.to_integer())
    {:noreply, push_redirect(socket, to: "/sh/#{slug}")}
  end

  def handle_event("mark-all-read", _, socket) do
    Profiles.mark_all_notifications_read(socket.assigns.profile)

    {:noreply,
     socket |> assign(notifications: Profiles.list_notifications(socket.assigns.profile.id))}
  end
end
