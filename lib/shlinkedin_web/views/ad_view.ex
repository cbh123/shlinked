defmodule ShlinkedinWeb.AdView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.AdView
  alias Shlinkedin.Ads

  def render("show.json", %{ad: ad}) do
    %{data: render_one(ad, AdView, "ad.json")}
  end

  def render("ad.json", %{ad: ad}) do
    owner = Ads.get_ad_owner(ad)
    creator = Shlinkedin.Profiles.get_profile_by_profile_id(ad.profile_id)

    %{
      body: ad.body,
      product: ad.product,
      gif_url: ad.gif_url,
      media_url: ad.media_url,
      owner: owner.persona_name,
      creator: creator.persona_name,
      price: Money.to_string(ad.price),
      updated_at: ad.updated_at
    }
  end
end
