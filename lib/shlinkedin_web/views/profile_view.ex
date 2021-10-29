defmodule ShlinkedinWeb.ProfileView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.ProfileView
  alias ShlinkedinWeb.EndorsementView
  alias ShlinkedinWeb.PostView
  alias Shlinkedin.Profiles

  def render("show.json", %{profile: profile}) do
    %{data: render_one(profile, ProfileView, "profile_with_post.json")}
  end

  def render("profile_with_post.json", %{profile: profile}) do
    profile = Shlinkedin.Repo.preload(profile, :posts)

    %{
      id: profile.id,
      name: profile.persona_name,
      username: profile.username,
      shlinkpoints: Money.to_string(profile.points),
      isPlatinum: Profiles.is_platinum?(profile),
      isModerator: Profiles.is_moderator?(profile),
      posts: render_many(profile.posts, PostView, "post.json"),
      endorsements: render_many(profile.endorsements, EndorsementView, "endorsement.json")
    }
  end

  def render("profile.json", %{profile: profile}) do
    %{
      id: profile.id,
      name: profile.persona_name,
      username: profile.username,
      shlinkpoints: Money.to_string(profile.points),
      isPlatinum: Profiles.is_platinum?(profile),
      isModerator: Profiles.is_moderator?(profile)
    }
  end

  def render_posts(posts) do
    posts |> Enum.slice(0..3) |> IO.inspect(label: "")
    %{data: render_many(posts, ProfileView, "post.json")}
  end
end
