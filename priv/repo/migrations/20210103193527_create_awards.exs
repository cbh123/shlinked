defmodule Shlinkedin.Repo.Migrations.CreateAwards do
  use Ecto.Migration

  def change do
    create table(:awards) do
      add :name, :string
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :active, :boolean

      timestamps()
    end

    create index(:awards, [:profile_id])
  end
end
