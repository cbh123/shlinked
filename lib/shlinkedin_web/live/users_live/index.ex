defmodule ShlinkedinWeb.UsersLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  @impl true
  def mount(params, session, socket) do
    # KNOWN BUG: RIGHT WHEN YOU CREATE AN ACCOUNT, THIS BUTTON DOESN"T WORK! PROBLABLY NOT LOADED INTO SOCKET!
    socket = is_user(session, socket)
    my_connections = get_connections(socket.assigns.profile)

    IO.inspect(my_connections, label: "my_connections")

    {:ok,
     socket
     |> assign(my_connections: my_connections)
     |> assign(profiles: Profiles.list_non_test_profiles())}
  end

  def check_between_friend_status(from, to) do
    Profiles.check_between_friend_status(from, to)
  end

  def get_connections(profile) do
    Profiles.get_unique_connection_ids(profile)
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
