defmodule Shlinkedin.Repo.Migrations.NotificationCascade do
  use Ecto.Migration

  def change do
    drop constraint(:notifications, :notifications_from_profile_id_fkey)

    alter table :notifications do
      modify :from_profile_id, references(:profiles, on_delete: :delete_all)
    end
  end
end
