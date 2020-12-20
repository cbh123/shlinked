defmodule Shlinkedin.Repo.Migrations.AddNotificationToAll do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :notify_all, :boolean, default: false
    end
  end
end
