defmodule Shlinkedin.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Timeline.Post

  schema "comments" do
    field :author, :string, default: "charlie"
    field :body, :string
    field :likes, :integer, default: 0
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, max: 240)
  end
end
