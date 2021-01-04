defmodule Shlinkedin.Profiles.Award do
  use Ecto.Schema
  import Ecto.Changeset

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
end
