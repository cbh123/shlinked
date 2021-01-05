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

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [:body, :media_url, :slug, :company, :product, :overlay])
    |> validate_required([:body, :company, :media_url])
  end
end
