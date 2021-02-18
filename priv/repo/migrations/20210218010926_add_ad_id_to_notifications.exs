defmodule Shlinkedin.Repo.Migrations.AddAdIdToNotifications do
  use Ecto.Migration

  def change do
    alter table :notifications do
      add :ad_id, references(:ads, on_delete: :nothing)
    end
    create index(:notifications, [:ad_id])
  end
end
