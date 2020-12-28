defmodule Shlinkedin.Timeline.CommentLike do
  use Ecto.Schema

  schema "comment_likes" do
    field :like_type, :string
    belongs_to :comment, Shlinkedin.Timeline.Comment
    belongs_to :profile, Shlinkedin.Profiles.Profile

    timestamps()
  end
end
