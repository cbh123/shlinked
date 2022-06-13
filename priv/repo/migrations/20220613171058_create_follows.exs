defmodule Shlinkedin.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:follows, [:from_profile_id])
    create index(:follows, [:to_profile_id])
    create unique_index(:follows, [:from_profile_id, :to_profile_id])
  end
end
