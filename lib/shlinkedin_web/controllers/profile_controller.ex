defmodule ShlinkedinWeb.ProfileController do
  use ShlinkedinWeb, :controller

  alias Shlinkedin.Profiles
  alias Shlinkedin.Repo

  action_fallback ShlinkedinWeb.FallbackController

  def show(conn, %{"slug" => slug}) do
    profile = Profiles.get_profile_by_slug!(slug)
    render(conn, "show.json", profile: profile)
  end

  def gallery(conn, %{"slug" => slug}) do
    profile = Profiles.get_profile_by_slug!(slug)
    ads = Shlinkedin.Ads.list_owned_ads(profile, paginate: %{page: 1, per_page: 10000})
    render(conn, "gallery.json", ads: ads)
  end

  def show_all(conn, %{"slug" => slug}) do
    profile = Profiles.get_profile_by_slug!(slug) |> Repo.preload(:posts)
    render(conn, "show_all.json", profile: profile)
  end
end
