defmodule ShlinkedinWeb.ProfileLive.ProfilesModal do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles

  def check_between_friend_status(from, to) do
    Profiles.check_between_friend_status(from, to)
  end

  def get_mutual_friends(from, to) do
    Profiles.get_mutual_friends(from, to)
  end
end
