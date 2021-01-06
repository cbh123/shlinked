defmodule Shlinkedin.Ads.Ad do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ads" do
    field :body, :string
    field :media_url, :string
    field :slug, :string
    belongs_to :profile, Shlinkedin.Profiles.Profile
    has_many :clicks, Shlinkedin.Ads.Click
    field :company, :string
    field :product, :string
    field :overlay, :string
    field :gif_url, :string
    field :overlay_color, :string

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [
      :body,
      :media_url,
      :slug,
      :company,
      :product,
      :overlay,
      :overlay_color,
      :gif_url
    ])
    |> validate_required([:body, :company])
    |> validate_length(:body, min: 0, max: 250)
    |> validate_length(:company, max: 50)
    |> validate_length(:product, max: 50)
    |> validate_length(:overlay, max: 50)
  end
end
