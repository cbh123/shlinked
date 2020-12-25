defmodule Shlinkedin.Repo.Migrations.AddArticleId do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :article_id, references(:articles, on_delete: :nilify_all)
    end
  end
end
