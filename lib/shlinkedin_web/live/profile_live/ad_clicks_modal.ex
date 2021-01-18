defmodule ShlinkedinWeb.ProfileLive.AdClicksModal do
  use ShlinkedinWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="bg-white px-4 py-4 border-b border-gray-200 sm:px-6 rounded-t-lg">
    <h3 class="text-lg leading-6 font-medium text-gray-900">
        <%= @title %>
    </h3>
    </div>

    <div class="p-5">



    <%= if @ad_clicks == [] do %>
    <div class="text-center">
        <p>No clicks 😞</p>
    </div>
    <% else %>
    <div class=" rounded-lg py-1">
        <%= for click <- @ad_clicks do %>
        <% ad = Shlinkedin.Ads.get_ad_preload_profile!(click.ad_id) %>
        <% clicker = Shlinkedin.Profiles.get_profile_by_profile_id(click.profile_id) %>


        <div class="flex w-full p-2 justify-between">

            <%= live_redirect to: Routes.ad_show_path(@socket, :show, click.ad_id) do %>
            <div class="flex hover:underline">
                <img class="h-10 w-10 rounded-lg object-cover" src="<%= if is_nil(ad.media_url), do: ad.gif_url, else: ad.media_url  %>" alt="">

                    <p class="ml-3 place-self-center text-sm text-gray-900"><%= clicker.persona_name %> clicked <%= @profile.persona_name %>'s ad for <%= ad.company %>
                    </p>


            </div>
            <% end %>

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
