defmodule Shlinkedin.Groups.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :status, :string
    belongs_to :profile, Shlinkedin.Profiles.Profile, foreign_key: :from_profile_id
    field :group_id, :id
    field :to_profile_id, :id
    field :note, :string

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:status, :note])
    |> validate_required([:status])
  end
end
