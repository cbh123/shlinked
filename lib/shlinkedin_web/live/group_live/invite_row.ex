defmodule ShlinkedinWeb.GroupLive.InviteRow do
  use ShlinkedinWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="flex" id="<%= @id %>">
    <%= case @member_status do %>
    <% "Member" -> %> <button
        class="inline-flex items-center px-3 py-1 border border-transparent shadow-sm text-xs font-semibold rounded-full text-gray-500 bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        Member</button>
    <% "Invited" -> %> <button
        class="inline-flex items-center px-3 py-1 border border-transparent shadow-sm text-xs font-semibold rounded-full text-gray-500 bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        Invited</button>
    <% "Invite" -> %> <button phx-click="invite" phx-value-id="<%= @match.id %>"
        class="inline-flex items-center px-3 py-1 border border-transparent shadow-sm text-xs font-semibold rounded-full text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">Invite</button>
    <% end %>
    </div>
    """
  end
end
