defmodule Shlinkedin.Repo.Migrations.AddShowLevelsToProfile do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :show_levels, :boolean, default: true
    end
  end
end
