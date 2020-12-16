defmodule Shlinkedin.Profiles.Friend do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friends" do
    field :status, :string
    field :message, :string
    belongs_to :profile, Shlinkedin.Profiles.Profile, foreign_key: :from_profile_id
    field :to_profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(friend, attrs) do
    friend
    |> cast(attrs, [:message, :status])
    |> validate_length(:message, max: 500)
  end
end
