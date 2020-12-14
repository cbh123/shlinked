defmodule Shlinkedin.Repo.Migrations.AddingLifeScoreAndBusinessJabs do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :life_score, :string, default: "B+"
      add :points, :integer, default: 100
    end

  end
end
