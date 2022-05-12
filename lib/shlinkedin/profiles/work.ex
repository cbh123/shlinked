defmodule Shlinkedin.Profiles.Work do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work" do
    belongs_to(:profile, Shlinkedin.Profiles.Profile)

    timestamps()
  end

  @doc false
  def changeset(work, attrs) do
    work
    |> cast(attrs, [])
    |> validate_required([])
  end
end
