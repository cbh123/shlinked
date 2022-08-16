defmodule ShlinkedinWeb.ProfileLive.RecommendedComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles

  def mount(assigns) do
    profiles = Profiles.recently_awarded_profiles(10) |> Enum.shuffle() |> Enum.take(3)

    {:ok,
     assigns
     |> assign(profiles: profiles)}
  end

  def render(assigns) do
    ~H"""
    <section aria-labelledby="who-to-follow-heading">
    <div class="bg-white rounded-lg shadow">
        <div class="p-6">
            <h2 id="who-to-follow-heading" class="text-base font-bold text-gray-900">Notable Shlinkers
            </h2>


            <div class="mt-6 flow-root">
                <ul role="list" class="-my-4 divide-y divide-gray-200">
                <%= for profile <- @profiles do %>
                    <li class="flex items-center py-4 space-x-3">
                        <div class="flex-shrink-0">
                            <img class="h-8 w-8 rounded-full"
                                src={profile.photo_url}
                                alt="">
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="text-sm font-medium text-gray-900">
                            <%= live_redirect profile.persona_name, to: Routes.profile_show_path(@socket, :show, profile.slug) %>
                            </p>
                            <p class="text-sm text-gray-500">
                            <%= live_redirect profile.username, to: Routes.profile_show_path(@socket, :show, profile.slug) %>
                            </p>
                        </div>
                        <div class="flex-shrink-0">
                          <%= live_component ShlinkedinWeb.ProfileLive.FollowButton,
                          id: "rec-follow-#{profile.id}",
                          follow_status: Shlinkedin.Profiles.is_following?(@profile, profile),
                          profile: @profile,
                          to_profile: profile
                          %>
                        </div>
                    </li>
                    <% end %>


                    <!-- More people... -->
                </ul>
            </div>

        </div>
    </div>
    </section>
    """
  end
end
