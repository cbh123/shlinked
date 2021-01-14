defmodule Shlinkedin.Repo.Migrations.AddNote do
  use Ecto.Migration

  def change do
    alter table :invites do
      add :note, :string
    end
  end
end
