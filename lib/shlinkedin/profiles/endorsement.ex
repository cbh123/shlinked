defmodule Shlinkedin.Profiles.Endorsement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "endorsements" do
    field :body, :string
    field :emoji, :string
    field :gif_url, :string
    field :from_profile_id, :id
    field :to_profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(endorsement, attrs) do
    endorsement
    |> cast(attrs, [:emoji, :body, :gif_url])
    |> validate_required([:body])
    |> validate_length(:body, min: 1, max: 50)
  end
end
