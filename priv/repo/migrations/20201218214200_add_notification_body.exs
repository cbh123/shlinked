defmodule Shlinkedin.Repo.Migrations.AddNotificationBody do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :body, :string
      add :action, :string
    end
  end
end
