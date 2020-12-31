defmodule Shlinkedin.Badges do
  alias Shlinkedin.Profiles.Profile
  import Phoenix.LiveView.Helpers

  def profile_badges(socket, %Profile{} = profile, size \\ 4) do
    is_featured(socket, profile, size)
  end

  defp is_featured(assigns, profile, size) do
    ~L"""
    <div class="inline-flex align-baseline">


    <%= if profile.verified do %>
    <div class="inline-flex tooltip">
        <svg class="w-<%= size %> h-<%= size %> inline-flex text-blue-500 " fill="currentColor" viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
        </svg>


        <span class="tooltip-text -mt-8">Verified</span>
    </div>
    <% end %>

    <%= if profile.featured do %>
    <div class="inline-flex tooltip px-0">
        <svg class="w-<%= size %> h-<%= size %> inline-flex text-yellow-500 " fill="currentColor" viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd"
                d="M5 2a1 1 0 011 1v1h1a1 1 0 010 2H6v1a1 1 0 01-2 0V6H3a1 1 0 010-2h1V3a1 1 0 011-1zm0 10a1 1 0 011 1v1h1a1 1 0 110 2H6v1a1 1 0 11-2 0v-1H3a1 1 0 110-2h1v-1a1 1 0 011-1zM12 2a1 1 0 01.967.744L14.146 7.2 17.5 9.134a1 1 0 010 1.732l-3.354 1.935-1.18 4.455a1 1 0 01-1.933 0L9.854 12.8 6.5 10.866a1 1 0 010-1.732l3.354-1.935 1.18-4.455A1 1 0 0112 2z"
                clip-rule="evenodd"></path>
        </svg>
        <span class="tooltip-text -mt-8">Featured Profile</span>
    </div>
    <% end %>

    </div>

    """
  end
end
