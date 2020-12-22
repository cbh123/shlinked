defmodule Shlinkedin.Repo.Migrations.CreateStoryViews do
  use Ecto.Migration

  def change do
    create table(:story_views) do
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :story_id, references(:stories, on_delete: :nothing)

      timestamps()
    end

    create index(:story_views, [:from_profile_id])
    create index(:story_views, [:story_id])
  end
end
