defmodule Shlinkedin.Repo.Migrations.AddWorkStreakToProfiles do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :work_streak, :integer, default: 0
    end
  end
end
