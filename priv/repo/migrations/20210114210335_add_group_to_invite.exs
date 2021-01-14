defmodule Shlinkedin.Repo.Migrations.AddGroupToInvite do
  use Ecto.Migration

  def change do
    alter table :invites do
      add :group_id, references(:groups, on_delete: :nothing)
    end

    create index(:invites, [:group_id])
  end
end
