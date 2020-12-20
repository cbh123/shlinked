defmodule Shlinkedin.Repo.Migrations.AddAdminColumn do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :admin, :boolean, default: false
    end
  end
end
