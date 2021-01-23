defmodule Shlinkedin.Profiles.ProfileView do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profile_views" do
    field :from_profile_id, :id
    field :to_profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(profile_view, attrs) do
    profile_view
    |> cast(attrs, [])
    |> validate_required([])
  end
end
