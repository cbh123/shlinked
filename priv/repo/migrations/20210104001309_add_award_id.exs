defmodule Shlinkedin.Repo.Migrations.AddAwardId do
  use Ecto.Migration

  def change do
    alter table :awards do
      add :award_id, references(:award_types, on_delete: :nothing)
    end

    create index(:awards, [:award_id])
  end
end
