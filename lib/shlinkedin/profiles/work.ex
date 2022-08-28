defmodule Shlinkedin.Profiles.Work do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work" do
    belongs_to(:profile, Shlinkedin.Profiles.Profile)
    field :weight, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(work, attrs) do
    work
    |> cast(attrs, [:weight])
    |> validate_required([])
  end
end
