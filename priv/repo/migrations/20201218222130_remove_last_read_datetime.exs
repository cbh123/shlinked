defmodule Shlinkedin.Repo.Migrations.RemoveLastReadDatetime do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      remove :last_read
      add :read, :boolean
    end
  end
end
