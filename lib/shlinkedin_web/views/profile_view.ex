defmodule ShlinkedinWeb.ProfileView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.{EndorsementView, TestimonialView, ProfileView, PostView}
  alias Shlinkedin.Profiles
  alias Shlinkedin.Ads

  def render("show.json", %{profile: profile}) do
    %{data: render_one(profile, ProfileView, "profile.json")}
  end

  def render("show_all.json", %{profile: profile}) do
    %{data: render_one(profile, ProfileView, "profile_all.json")}
  end

  def render("profile_all.json", %{profile: profile}) do
    endorsements = Profiles.list_endorsements(profile.id)
    reviews = Profiles.list_testimonials(profile.id)
    ads = Ads.list_owned_ads(profile.id, page: 1, per_page: 10000)

    %{
      id: profile.id,
      name: profile.persona_name,
      username: profile.username,
      shlinkpoints: Money.to_string(profile.points),
      isPlatinum: Profiles.is_platinum?(profile),
      isModerator: Profiles.is_moderator?(profile),
      posts: render_many(profile.posts, PostView, "post.json"),
      endorsements: render_many(endorsements, EndorsementView, "endorsement.json"),
      reviews: render_many(reviews, TestimonialView, "testimonial.json"),
      gallery: render_many(ads, TestimonialView, "testimonial.json")
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
end
