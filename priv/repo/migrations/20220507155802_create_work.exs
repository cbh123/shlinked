defmodule Shlinkedin.Repo.Migrations.CreateWork do
  use Ecto.Migration

  def change do
    create table(:work) do
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:work, [:profile_id])
  end
end
