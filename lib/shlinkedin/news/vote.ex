defmodule Shlinkedin.News.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_votes" do
    belongs_to :article, Shlinkedin.News.Article
    belongs_to :profile, Shlinkedin.Profiles.Profile

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [])
    |> validate_required([])
  end
end
