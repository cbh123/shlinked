defmodule Shlinkedin.Repo.Migrations.AddProfileTypeTimePreferences do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :feed_type, :string, default: "reactions"
      add :feed_time, :string, default: "week"
    end
  end
end
