defmodule Shlinkedin.Repo.Migrations.AddUnsubscribe do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :unsubscribed, :boolean, default: false
    end
  end
end
