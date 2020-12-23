defmodule Shlinkedin.Repo.Migrations.AddProfileUnreadNotifications do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :last_checked_notifications, :naive_datetime
    end
  end
end
