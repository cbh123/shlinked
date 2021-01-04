defmodule Shlinkedin.Repo.Migrations.MakeActiveAwardTrue do
  use Ecto.Migration

  def change do
    alter table :awards do
      modify  :active, :boolean, default: true
    end
  end
end
