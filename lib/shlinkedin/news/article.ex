defmodule Shlinkedin.News.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :headline, :string
    field :media_url, :string
    field :slug, :string
    field :profile_id, :id
    has_many :votes, Shlinkedin.News.Vote, on_delete: :nilify_all

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:headline, :media_url])
    |> validate_required([:headline])
  end
end
