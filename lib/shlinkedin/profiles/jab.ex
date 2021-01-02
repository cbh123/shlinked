defmodule Shlinkedin.Profiles.Jab do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jabs" do
    field :from_profile_id, :id
    field :to_profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(jab, attrs) do
    jab
    |> cast(attrs, [])
    |> validate_required([])
  end
end
