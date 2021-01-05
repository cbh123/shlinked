defmodule Shlinkedin.Repo.Migrations.CreateClicks do
  use Ecto.Migration

  def change do
    create table(:clicks) do
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :ad_id, references(:ads, on_delete: :nothing)

      timestamps()
    end

    create index(:clicks, [:profile_id])
    create index(:clicks, [:ad_id])
  end
end
