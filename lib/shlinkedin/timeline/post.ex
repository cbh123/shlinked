defmodule Shlinkedin.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field(:likes_count, :integer, default: 0)
    field(:reposts_count, :integer, default: 0)
    has_many(:comments, Shlinkedin.Timeline.Comment, on_delete: :nilify_all)
    has_many(:likes, Shlinkedin.Timeline.Like, on_delete: :nilify_all)
    belongs_to(:profile, Shlinkedin.Accounts.Profile)
    field :photo_url, :string
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, max: 500)
  end
end
