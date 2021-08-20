defmodule Shlinkedin.Repo.Migrations.AddJoinedDiscord do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :joined_discord, :boolean, default: false
    end
  end
end
