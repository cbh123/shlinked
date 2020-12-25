defmodule Shlinkedin.News.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_votes" do
    field :article_id, :id
    field :profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [])
    |> validate_required([])
  end
end
