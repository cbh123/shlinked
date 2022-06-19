defmodule ShlinkedinWeb.ProfileLive.FollowButton do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles
  alias Shlinkedin.Awards

  def handle_event(_event, _params, %{assigns: %{profile: nil}} = socket) do
    {:noreply,
     socket
     |> push_redirect(to: Routes.user_registration_path(socket, :new))}
  end

  def handle_event("follow", %{"id" => id}, %{assigns: %{profile: profile}} = socket) do
    to_profile = Profiles.get_profile_by_profile_id(id)
    {:ok, _follow} = Profiles.create_follow(profile, to_profile)

    if Profiles.count_following(profile) == 1 do
      {:ok, _profile} = Profiles.update_profile(profile, %{has_sent_one_shlink: true})
    end

    # send networking virginity award and SPs
    if first_ever_shlink?(profile) do
      god = Profiles.get_god()

      award_type =
        Awards.get_or_create_award_type(%{
          "name" => "Networking Virginity",
          "emoji" => "🤝",
          "description" => "I just lost my Networking Virginity!"
        })

      {:ok, _award} = Profiles.grant_award(god, profile, award_type)
    end

    random_emoji = ["🎉", "🤝", "💉", "HUSTLE", "🧨"] |> Enum.random()

    send_update(ShlinkedinWeb.ProfileLive.FollowButton,
      id: id,
      follow_status: "following"
    )

    {:noreply, socket |> push_event("confetti-cannon", %{emoji: random_emoji})}
  end

  def handle_event("unfollow", %{"id" => id}, socket) do
    to_profile = Profiles.get_profile_by_profile_id(id)
    Profiles.unfollow(socket.assigns.profile, to_profile)

    send_update(ShlinkedinWeb.ProfileLive.FollowButton,
      id: id,
      follow_status: nil
    )

    {:noreply, socket |> push_event("confetti-cannon", %{emoji: "🖕"})}
  end

  def first_ever_shlink?(profile) do
    Profiles.count_following(profile) == 1 and not profile.has_sent_one_shlink
  end

  def render(assigns) do
    ~L"""
    <div phx-hook="Confetti" class="inline-flex" id="<%= @id %>" phx-update="replace">
    <%= case @follow_status do %>
    <% "me" -> %>
    <h5
    class="inline-flex items-center px-3 py-2 border border-transparent text-xs font-semibold rounded-full text-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
    Me
    </h5>
    <% nil -> %>
    <button type="button" phx-click="follow" phx-target="<%= @myself %>" phx-value-id="<%= @to_profile.id %>"
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

    <% _ ->  %>
    <button type="button" phx-click="unfollow" data-confirm="Are you sure you want to unshlink?" phx-target="<%= @myself %>" phx-value-id="<%= @to_profile.id %>"
        class="inline-flex items-center px-3 py-2 border border-green-600 shadow-sm text-xs font-semibold rounded-full text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        <!-- Heroicon name: mail -->

        <svg class="-ml-1 mr-2 h-3 w-3" fill="currentColor" viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"></path>
        </svg>
        Unshlink
    </button>

    <%= if first_ever_shlink?(@profile) do %>
    <div id={"modal"} phx-target={@id} phx-hook="Confetti" x-data="{ open: true }" x-init="() => {
        setTimeout(() => open = true, 100);
        $watch('open', isOpen => $dispatch('modal-change', { open: isOpen, id: '{@id}' }))
        }" x-on:close-now="open = false" x-show="open" class="fixed bottom-0 z-50 px-4 pb-4 inset-0">

        <!-- BACKDROP -->
        <div x-show="open" x-transition:enter="ease-out duration-300" x-transition:enter-start="opacity-0"
            x-transition:enter-end="opacity-100" x-transition:leave="ease-in duration-200"
            x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
            class="fixed inset-0 transition-opacity">
            <div class="absolute inset-0 bg-gray-900 opacity-50"></div>
        </div>

        <!-- MODAL DIALOG -->
        <div x-show="open" x-transition:enter="ease-out duration-300"
            x-transition:enter-start="opacity-0 mb-2 sm:mb-8 sm:mt-2 sm:scale-95"
            x-transition:enter-end="opacity-100 mb-8 sm:mt-8 sm:scale-100" x-transition:leave="ease-in duration-200"
            x-transition:leave-start="opacity-100  mb-8 sm:mt-8  sm:scale-100"
            x-transition:leave-end="opacity-0  mb-2 sm:mb-8 sm:mt-2  sm:scale-95"
            class="relative w-full max-w-lg px-4 mx-auto my-8 shadow-lg sm:px-0">

            <div @click.away="open = false" @keydown.escape.window="open = false"
                class="relative flex flex-col bg-white rounded-lg">
                <!-- MODAL HEADER -->
                <div class="flex items-center justify-between p-4 rounded-t bg-gray-100">
                    <h5 class="mb-0 text-base font-semibold bg-gray-100 font-windows">CONGRATULATIONS!</h5>
                    <button type="button" @click="open = false"
                        class="text-gray-400 hover:text-gray-500 focus:outline-none focus:text-gray-500 transition ease-in-out duration-150">
                        &times;
                    </button>
                </div>
                <!-- MODAL BODY -->
                <div class="p-5 rounded-b-lg font-windows bg-white">

                    <p class="">You just lost your Networking Virginity! This is your reward. Keep it up!</p>


                    <p class="italic">- ShlinkedIn HQ</p>

                    <div class="text-center animate-fadeDown">
                        <p class="text-8xl text-center">🤝</p>
                        <p>Your new Networking Virginity award has been added to your <%= live_redirect "Trophy Case", to: Routes.profile_show_path(@socket, :show, @profile.slug), class: "text-blue-500 underline hover:text-blue-600" %></p>

                        <p></p>
                    </div>

                </div>

            </div>
        </div>
    </div>
    <% end %>



    <% end %>
    </div>
    """
  end
end
