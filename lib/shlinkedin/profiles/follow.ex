defmodule Shlinkedin.Profiles.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do
    belongs_to :profile, Shlinkedin.Profiles.Profile, foreign_key: :from_profile_id
    field :to_profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:to_profile_id, name: :follows_from_profile_id_to_profile_id_index)
  end

  def validate_not_following_yourself(
        %Ecto.Changeset{
          data: %Shlinkedin.Profiles.Follow{
            from_profile_id: from_profile_id,
            to_profile_id: to_profile_id
          }
        } = changeset,
        :to_profile_id
      ) do
    validate_change(changeset, :to_profile_id, fn
      :to_profile_id, _follow ->
        changeset |> IO.inspect(label: "changeset bloop")

        if from_profile_id == to_profile_id do
          [to_profile_id: "You cannot follow yourself!"]
        else
          []
        end
    end)
  end
end
