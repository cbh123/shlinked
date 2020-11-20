defmodule Shlinkedin.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :author, :string
    field :body, :string
    field :likes, :integer
    belongs_to :post, Timeline.Post

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :author, :likes])
    |> validate_required([:body, :author, :likes])
  end
end
