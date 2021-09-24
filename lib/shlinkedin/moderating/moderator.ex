defmodule Shlinkedin.Moderating.Moderator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "moderators" do
    field :moderator_class, :string
    belongs_to :profile, Shlinkedin.Profiles.Profile

    timestamps()
  end

  @doc false
  def changeset(granter, moderator, attrs) do
    moderator
    |> cast(attrs, [:moderator_class])
    |> validate_granter(granter)
    |> validate_required([:moderator_class])
  end

  @doc """
  Validates that the granter of moderating power is
  allowed to do that.
  """
  def validate_granter(%Ecto.Changeset{}, granter) do
    validate_change(changeset, :moderator_class, fn :moderator_class, _class ->
      if
    end)
  end
end
