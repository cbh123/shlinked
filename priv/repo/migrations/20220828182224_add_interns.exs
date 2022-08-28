defmodule Shlinkedin.Repo.Migrations.AddInterns do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :interns, :integer, default: 0
    end
  end
end
