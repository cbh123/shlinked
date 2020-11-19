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
    field :post_profile_picture, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :post_name, :post_profile_picture])
    |> validate_required([:body, :post_name, :post_profile_picture])
    |> validate_length(:body, min: 2, max: 1000)
    |> validate_length(:post_name, min: 2, max: 40)
  end
end
