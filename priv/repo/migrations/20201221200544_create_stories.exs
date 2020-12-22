defmodule Shlinkedin.Repo.Migrations.CreateStories do
  use Ecto.Migration

  def change do
    create table(:stories) do
      add :profile_id, references(:profiles)
      add :body, :string
      add :media_url, :string
      timestamps()
    end

    create index(:stories, [:profile_id])
  end
end
