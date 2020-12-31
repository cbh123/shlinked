defmodule Shlinkedin.Badges do
  alias Shlinkedin.Profiles.Profile
  import Phoenix.LiveView.Helpers

  def profile_badges(socket, %Profile{} = profile, size \\ 4) do
    is_featured(socket, profile, size)
  end

  defp is_featured(assigns, profile, size) do
    ~L"""
    <%= if profile.featured do %>
    <div class="inline-flex tooltip">
        <svg class="w-<%= size %> h-<%= size %> inline-flex text-yellow-500 " fill="currentColor" viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd"
                d="M5 2a1 1 0 011 1v1h1a1 1 0 010 2H6v1a1 1 0 01-2 0V6H3a1 1 0 010-2h1V3a1 1 0 011-1zm0 10a1 1 0 011 1v1h1a1 1 0 110 2H6v1a1 1 0 11-2 0v-1H3a1 1 0 110-2h1v-1a1 1 0 011-1zM12 2a1 1 0 01.967.744L14.146 7.2 17.5 9.134a1 1 0 010 1.732l-3.354 1.935-1.18 4.455a1 1 0 01-1.933 0L9.854 12.8 6.5 10.866a1 1 0 010-1.732l3.354-1.935 1.18-4.455A1 1 0 0112 2z"
                clip-rule="evenodd"></path>
        </svg>
        <span class="tooltip-text -mt-8">Featured Profile</span>
    </div>
    <% end %>
    """
  end
end
