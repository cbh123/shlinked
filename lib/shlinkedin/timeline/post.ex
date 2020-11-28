defmodule Shlinkedin.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :likes_count, :integer, default: 0
    field :reposts_count, :integer, default: 0
    field :username, :string, default: "charlie"
    field :post_name, :string
    field :post_title, :string
    has_many :comments, Shlinkedin.Timeline.Comment, on_delete: :nilify_all
    belongs_to :profile, Shlinkedin.Accounts.Profile
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, max: 1000)
  end
end
