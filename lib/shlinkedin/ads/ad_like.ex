defmodule Shlinkedin.Ads.AdLike do
  use Ecto.Schema

  schema "ad_likes" do
    field :like_type, :string
    belongs_to :ad, Shlinkedin.Ads.Ad
    belongs_to :profile, Shlinkedin.Profiles.Profile

    timestamps()
  end
end
