defmodule Shlinkedin.Ads.Ad do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ads" do
    field :body, :string
    field :media_url, :string
    field :slug, :string
    field :profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [:body, :media_url, :slug])
    |> validate_required([:body, :media_url, :slug])
  end
end
