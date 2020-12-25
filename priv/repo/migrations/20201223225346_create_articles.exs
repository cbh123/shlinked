defmodule Shlinkedin.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :headline, :string
      add :slug, :string
      add :media_url, :string
      add :body, :text
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:articles, [:profile_id])
  end
end
