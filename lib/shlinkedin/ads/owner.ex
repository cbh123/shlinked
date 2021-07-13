defmodule Shlinkedin.Ads.Owner do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ad_owners" do
    field(:ad_id, :id)
    field(:transaction_id, :id)
    field(:profile_id, :id)

    timestamps()
  end

  @doc false
  def changeset(owners, attrs) do
    owners
    |> cast(attrs, [:ad_id, :transaction_id, :profile_id])
    |> validate_required([:ad_id, :profile_id])
  end
end
