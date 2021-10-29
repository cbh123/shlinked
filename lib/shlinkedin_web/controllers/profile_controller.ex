defmodule ShlinkedinWeb.ProfileController do
  use ShlinkedinWeb, :controller

  alias Shlinkedin.Profiles

  action_fallback ShlinkedinWeb.FallbackController

  def show(conn, %{"slug" => slug}) do
    profile = Profiles.get_profile_by_slug!(slug) |> IO.inspect(label: "profile")
    render(conn, "show.json", profile: profile)
  end
end
