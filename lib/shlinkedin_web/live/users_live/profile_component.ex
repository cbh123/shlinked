defmodule ShlinkedinWeb.UsersLive.ProfileComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile

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
      id: "profile-#{to_profile.id}",
      friend_status: Profiles.check_between_friend_status(socket.assigns.profile, to_profile)
    )

    {:noreply, socket}
  end

  def handle_event("unfriend", %{"to-profile" => id}, socket) do
    to_profile = Profiles.get_profile_by_profile_id(id)
    Profiles.cancel_friend_request(socket.assigns.profile, to_profile)

    send_update(ShlinkedinWeb.UsersLive.ProfileComponent,
      id: "profile-#{to_profile.id}",
      friend_status: Profiles.check_between_friend_status(socket.assigns.profile, to_profile)
    )

    {:noreply, socket}
  end

  defp same_profile?(%Profile{} = profile1, %Profile{} = profile2) do
    profile1 == profile2
  end

  defp same_profile?(%Profile{}, nil), do: false
end
