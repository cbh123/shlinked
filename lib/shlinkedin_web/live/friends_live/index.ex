defmodule ShlinkedinWeb.FriendLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  @impl true
  def mount(params, session, socket) do
    # KNOWN BUG: RIGHT WHEN YOU CREATE AN ACCOUNT, THIS BUTTON DOESN"T WORK! PROBLABLY NOT LOADED INTO SOCKET!
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(:from_notifications, Map.has_key?(params, "notifications"))
     |> assign(connections: Profiles.get_connections(socket.assigns.profile))
     |> assign(requests: Profiles.get_pending_requests(socket.assigns.profile))}
  end

  @impl true
  def handle_event("reject-request", %{"from-profile-id" => id}, socket) do
    from_profile = Profiles.get_profile_by_profile_id(id)

    Profiles.cancel_friend_request(from_profile, socket.assigns.profile)

    {:noreply,
     socket
     |> assign(connections: Profiles.get_connections(socket.assigns.profile))
     |> assign(requests: Profiles.get_pending_requests(socket.assigns.profile))}
  end

  @impl true
  def handle_event("accept-request", %{"from-profile-id" => id}, socket) do
    from_profile = Profiles.get_profile_by_profile_id(id)
    Profiles.accept_friend_request(from_profile, socket.assigns.profile)

    {:noreply,
     socket
     |> assign(connections: Profiles.get_connections(socket.assigns.profile))
     |> assign(requests: Profiles.get_pending_requests(socket.assigns.profile))}
  end
end
