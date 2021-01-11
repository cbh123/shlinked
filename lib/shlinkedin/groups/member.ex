defmodule Shlinkedin.Groups.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :ranking, :string, default: "member"
    belongs_to :profile, Shlinkedin.Profiles.Profile
    belongs_to :group, Shlinkedin.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:ranking])
    |> validate_required([:ranking])
  end
end
