defmodule Shlinkedin.Repo.Migrations.ReadDefaultFalse do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      modify :read, :boolean, default: false
    end
  end
end
