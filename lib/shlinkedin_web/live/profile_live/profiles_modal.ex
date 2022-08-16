defmodule ShlinkedinWeb.ProfileLive.ProfilesModal do
  use ShlinkedinWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="bg-white px-4 py-4 border-b border-gray-200 sm:px-6 rounded-t-lg">
    <h3 class="text-lg leading-6 font-medium text-gray-900">
        <%= @title %>
    </h3>
    </div>

    <div class="p-5">



    <%= if @profiles == [] do %>
    <div class="text-center">
        <p>No one here 😞</p>
    </div>
    <% else %>
    <div class=" rounded-lg py-1">
        <%= for profile <- @profiles do %>


        <div class="flex w-full p-2 justify-between">

            <%= live_redirect to: Routes.profile_show_path(@socket, :show, profile.slug) do %>
            <div class="flex hover:underline">
                <img class="h-10 w-10 rounded-full object-cover" src="<%= profile.photo_url %>" alt="">

                <div>
                    <p class="ml-3 place-self-center text-sm font-medium text-gray-900"><%= profile.persona_name %>
                    </p>
                    <% mutual_friends = Shlinkedin.Profiles.get_mutual_friends(@profile, profile)  %>
                    <p class="font-semibold ml-3 text-xs text-gray-400">
                        <%= length(mutual_friends) %> Mutual
                    </p>
                </div>
            </div>
            <% end %>

            <div class="block">
                <%= live_component @socket, ShlinkedinWeb.ProfileLive.FollowButton,
                        id: "modal-#{profile.id}",
                        follow_status: Shlinkedin.Profiles.is_following?(@profile, profile),
                        profile: @profile,
                        to_profile: profile
                        %>
            </div>

        </div>
        <% end %>



    </div>
    <% end %>







    <div class="flex justify-end mt-8 bg-gray-100 -m-5 p-5 rounded-b-lg">

        <%= live_patch "Done", to: @return_to, class: "ml-3 inline-flex justify-center py-2 px-4 border border-gray-300 shadow-sm text-sm font-medium rounded-full text-gray-600  bg-white hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"%>
    </div>




    </div>

    """
  end
end
