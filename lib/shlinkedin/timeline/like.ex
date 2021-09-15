defmodule Shlinkedin.Timeline.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    field :like_type, :string
    belongs_to :post, Shlinkedin.Timeline.Post
    belongs_to :profile, Shlinkedin.Profiles.Profile

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:like_type, :post_id, :profile_id])
    |> validate_required([:like_type, :post_id, :profile_id])
  end
end
