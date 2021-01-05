defmodule Shlinkedin.Ads.Click do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clicks" do
    belongs_to :profile, Shlinkedin.Profiles.Profile
    belongs_to :ad, Shlinkedin.Ads.Ad
    timestamps()
  end

  @doc false
  def changeset(click, attrs) do
    click
    |> cast(attrs, [])
    |> validate_required([])
  end
end
