defmodule Shlinkedin.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :user_id, references(:users, on_delete: :nothing)
      add :slug, :string, null: false
      add :username, :string, null: false
      timestamps()
    end

    create unique_index(:profiles, [:user_id])
    create unique_index(:profiles, [:username])
    create unique_index(:profiles, [:slug])
  end
end
