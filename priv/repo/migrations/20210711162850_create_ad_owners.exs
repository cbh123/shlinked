defmodule Shlinkedin.Repo.Migrations.CreateAdOwners do
  use Ecto.Migration

  def change do
    create table(:ad_owners) do
      add :ad_id, references(:ads, on_delete: :nothing)
      add :transaction_id, references(:transactions, on_delete: :nothing)
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:ad_owners, [:ad_id])
    create index(:ad_owners, [:transaction_id])
    create index(:ad_owners, [:profile_id])
  end
end
