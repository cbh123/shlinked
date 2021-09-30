defmodule Shlinkedin.Repo.Migrations.AddRemovedToComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add(:removed, :boolean, default: false)
    end
  end
end
