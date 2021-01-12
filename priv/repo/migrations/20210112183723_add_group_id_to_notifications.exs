defmodule Shlinkedin.Repo.Migrations.AddGroupIdToNotifications do
  use Ecto.Migration

  def change do
    alter table :notifications do
      add :group_id, references(:groups, on_delete: :nothing)
    end
    create index(:notifications, [:group_id])
  end
end
