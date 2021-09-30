defmodule Shlinkedin.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    has_many(:likes, Shlinkedin.Timeline.CommentLike, on_delete: :nilify_all)
    belongs_to :post, Shlinkedin.Timeline.Post
    belongs_to :profile, Shlinkedin.Profiles.Profile
    field :profile_tags, {:array, :string}, default: []
    field :removed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :profile_tags])
    |> validate_required([:body])
    |> validate_length(:body, max: 500)
  end
end
