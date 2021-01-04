defmodule Shlinkedin.Repo.Migrations.MakePrivateMode do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :private_mode, :boolean, default: false
    end
  end
end
