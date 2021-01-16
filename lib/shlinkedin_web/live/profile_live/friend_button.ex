defmodule ShlinkedinWeb.ProfileLive.FriendButton do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles

  def handle_event("send-friend-request", %{"id" => id}, socket) do
    to_profile = Profiles.get_profile_by_profile_id(id)
    Profiles.send_friend_request(socket.assigns.profile, to_profile)

    send_update(ShlinkedinWeb.ProfileLive.FriendButton,
      id: to_profile.id,
      friend_status: Profiles.check_between_friend_status(socket.assigns.profile, to_profile)
    )

    {:noreply, socket}
  end

  def handle_event("unfriend", %{"id" => id}, socket) do
    to_profile = Profiles.get_profile_by_profile_id(id)
    Profiles.cancel_friend_request(socket.assigns.profile, to_profile)

    send_update(ShlinkedinWeb.ProfileLive.FriendButton,
      id: to_profile.id,
      friend_status: Profiles.check_between_friend_status(socket.assigns.profile, to_profile)
    )

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="inline-flex" id="<%= @id %>">
    <%= case @friend_status do %>
    <% nil -> %>
    <button type="button" phx-click="send-friend-request" phx-target="<%= @myself %>" phx-value-id="<%= @to_profile.id %>"
        class="inline-flex items-center px-3 py-2 border border-transparent shadow-sm text-xs font-semibold rounded-full text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        <!-- Heroicon name: mail -->
        <svg class="-ml-1 mr-2 h-3 w-3" fill="currentColor" viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg">
            <path
                d="M8 9a3 3 0 100-6 3 3 0 000 6zM8 11a6 6 0 016 6H2a6 6 0 016-6zM16 7a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z">
            </path>
        </svg>
        Shlink
    </button>


    <% "pending" ->  %>

    <button type="button" phx-click="unfriend" data-confirm="Are you sure you want to destroy this request?" phx-target="<%= @myself %>" phx-value-id="<%= @to_profile.id %>"
        class="inline-flex items-center px-3 py-2 border border-gray-600 shadow-sm text-xs font-semibold rounded-full text-gray-600 bg-white hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        <!-- Heroicon name: mail -->
        <svg class="-ml-1 mr-2 h-3 w-3 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        Pending
    </button>

    <% "accepted" ->  %>

    <button type="button" phx-click="unfriend" data-confirm="Are you sure you want to unshlink?" phx-target="<%= @myself %>" phx-value-id="<%= @to_profile.id %>"
        class="inline-flex items-center px-3 py-2 border border-green-600 shadow-sm text-xs font-semibold rounded-full text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        <!-- Heroicon name: mail -->

        <svg class="-ml-1 mr-2 h-3 w-3" fill="currentColor" viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"></path>
        </svg>
        Shlinked
    </button>


    <% end %>
    </div>
    """
  end
end
