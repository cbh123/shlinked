defmodule Shlinkedin.Repo.Migrations.CreateJabs do
  use Ecto.Migration

  def change do
    create table(:jabs) do
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:jabs, [:from_profile_id])
    create index(:jabs, [:to_profile_id])
  end
end
