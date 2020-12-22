defmodule ShlinkedinWeb.UsersLive.ProfileComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles

  def check_between_friend_status(from, to) do
    Profiles.check_between_friend_status(from, to)
  end

  def get_mutual_friends(from, to) do
    Profiles.get_mutual_friends(from, to)
  end

  def handle_event("send-friend-request", %{"to-profile" => id}, socket) do
    to_profile = Profiles.get_profile_by_profile_id(id)
    Profiles.send_friend_request(socket.assigns.profile, to_profile)

    send_update(ShlinkedinWeb.UsersLive.ProfileComponent,
      id: to_profile.id,
      friend_status: Profiles.check_between_friend_status(socket.assigns.profile, to_profile)
    )

    {:noreply, socket}
  end

  def handle_event("unfriend", %{"to-profile" => id}, socket) do
    to_profile = Profiles.get_profile_by_profile_id(id)
    Profiles.cancel_friend_request(socket.assigns.profile, to_profile)

    send_update(ShlinkedinWeb.UsersLive.ProfileComponent,
      id: to_profile.id,
      friend_status: Profiles.check_between_friend_status(socket.assigns.profile, to_profile)
    )

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""




    <li id="<%= @id %>"
    class="col-span-1 row-span-1 flex flex-1 flex-col text-center bg-white rounded-lg shadow divide-y divide-gray-200">
    <div class="flex-1 py-2 px-8">
        <dd class="my-2">
            <%= if Timex.diff(DateTime.utc_now(), @show_profile.inserted_at, :days) < 5 do %>

            <span class="px-2 py-1 text-green-800 text-xs font-medium bg-green-100 rounded-full mb-2 ">Recently
                Joined</span>
            <% else %>
            <span class="px-2 py-1 text-green-800 text-xs font-medium rounded-full mb-2 "></span>
            <% end %>
        </dd>


        <%= live_redirect to: Routes.profile_show_path(@socket, :show, @show_profile.slug) do %>

        <img class="w-32 h-32 mx-auto bg-black rounded-full object-cover" src="<%= @show_profile.photo_url %>" alt="">
        <h3 class="mt-6 text-gray-900 text-sm font-medium"><%= @show_profile.persona_name %></h3>

        <% end %>

        <dl class="mt-1 flex-grow flex flex-col justify-between">
            <dt class="sr-only">Title</dt>
            <dd class="text-gray-500 text-sm"><%= @show_profile.persona_title%> </dd>
            <dt class="sr-only">Role</dt>


            <% mutual_friends = get_mutual_friends(@profile, @show_profile)  %>
            <p class="font-sm text-gray-500 font-semibold">
            <%= length(mutual_friends) %> Mutual Shlinks
            </p>





            <%= if @show_profile.id != @profile.id do %>
            <div class="mt-4">
                <%= case @friend_status do %>
                <% nil -> %>
                <button type="button" phx-click="send-friend-request" phx-value-to-profile="<%= @show_profile.id %>" phx-target="<%= @myself %>"
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

                <button type="button" phx-click="unfriend" phx-value-to-profile="<%= @show_profile.id %>" phx-target="<%= @myself %>"
                    data-confirm="Are you sure you want to destroy your request?"
                    class="inline-flex items-center px-3 py-2 border border-gray-600 shadow-sm text-xs font-semibold rounded-full text-gray-600 bg-white hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                    <!-- Heroicon name: mail -->
                    <svg class="-ml-1 mr-2 h-3 w-3 animate-spin" fill="none" stroke="currentColor"
                        viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    Pending
                </button>

                <% "accepted" ->  %>

                <button type="button" phx-value-to-profile="<%= @show_profile.id %>" phx-click="unfriend" phx-target="<%= @myself %>"
                    data-confirm="Are you sure you want to unshlink?"
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
            <% end %>

        </dl>
    </div>
    <div>
        <div class="-mt-px flex divide-x divide-gray-200">
            <div class="w-0 flex-1 flex">



                <div class="-ml-px w-0 flex-1 flex">
                    <%= live_redirect raw("See Profile &rarr;"), to: Routes.profile_show_path(@socket, :show, @show_profile.slug), class: "relative w-0 flex-1 inline-flex items-center justify-center py-4 text-sm text-gray-700 font-medium border border-transparent rounded-br-lg hover:text-gray-500" %>

                </div>
            </div>
        </div>

    </li>

    """
  end
end
