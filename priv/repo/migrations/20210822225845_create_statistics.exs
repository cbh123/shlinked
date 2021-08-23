defmodule Shlinkedin.Repo.Migrations.CreateStatistics do
  use Ecto.Migration

  def change do
    create table(:statistics) do
      add :total_points, :integer

      timestamps()
    end

  end
end
