defmodule Shlinkedin.Repo.Migrations.AddPinToPosts do
  use Ecto.Migration

  def change do
    alter table :posts do
      add :pinned, :boolean, default: false
    end
  end
end
