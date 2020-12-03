defmodule Shlinkedin.Timeline.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    field :from_name, :string
    field :like_type, :string
    belongs_to :post, Shlinkedin.Timeline.Post
    belongs_to :profile, Shlinkedin.Accounts.Profile

    timestamps()
  end
end
