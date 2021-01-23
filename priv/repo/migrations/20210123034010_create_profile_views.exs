defmodule Shlinkedin.Repo.Migrations.CreateProfileViews do
  use Ecto.Migration

  def change do
    create table(:profile_views) do
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:profile_views, [:from_profile_id])
    create index(:profile_views, [:to_profile_id])
  end
end
