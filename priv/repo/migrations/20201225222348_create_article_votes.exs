defmodule Shlinkedin.Repo.Migrations.CreateArticleVotes do
  use Ecto.Migration

  def change do
    create table(:article_votes) do
      add :article_id, references(:articles, on_delete: :nothing)
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:article_votes, [:article_id])
    create index(:article_votes, [:profile_id])
  end
end
