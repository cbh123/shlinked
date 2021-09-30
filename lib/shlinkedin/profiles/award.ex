defmodule Shlinkedin.Profiles.Award do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Profiles

  schema "awards" do
    field :name, :string
    belongs_to :profile, Shlinkedin.Profiles.Profile
    belongs_to :award_type, Shlinkedin.Awards.AwardType, foreign_key: :award_id
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(awards, attrs) do
    awards
    |> cast(attrs, [:name, :active])
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_authorized(changeset, granter) do
    if Profiles.is_admin?(granter) do
      changeset
    else
      add_error(changeset, :profile_id, "Not authorized!")
    end
  end
end
