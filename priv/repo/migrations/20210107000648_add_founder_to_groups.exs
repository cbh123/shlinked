defmodule Shlinkedin.Repo.Migrations.AddFounderToGroups do
  use Ecto.Migration

  def change do
    alter table :groups do
      add :profile_id, references(:profiles, on_delete: :nothing)
    end
    create index(:groups, [:profile_id])
  end
end
