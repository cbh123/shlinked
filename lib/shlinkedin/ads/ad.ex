defmodule Shlinkedin.Ads.Ad do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ads" do
    field :body, :string
    field :media_url, :string
    field :slug, :string
    field :profile_id, :id
    field :company, :string
    field :product, :string
    field :overlay, :string
    field :gif_url, :string

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [:body, :media_url, :slug, :company, :product, :overlay, :gif_url])
    |> validate_required([:body, :company])
  end
end
