defmodule Shlinkedin.Profiles.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :body, :string
    field :email, :string
    field :profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:email, :body])
    |> validate_email()
    |> validate_required([:email, :body])
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end
end
