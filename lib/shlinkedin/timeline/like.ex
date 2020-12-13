defmodule Shlinkedin.Timeline.Like do
  use Ecto.Schema

  schema "likes" do
    field :like_type, :string
    belongs_to :post, Shlinkedin.Timeline.Post
    belongs_to :profile, Shlinkedin.Profiles.Profile

    timestamps()
  end
end
