defmodule Shlinkedin.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :ranking, :string, default: "member"
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:members, [:profile_id])
    create index(:members, [:group_id])
  end
end
