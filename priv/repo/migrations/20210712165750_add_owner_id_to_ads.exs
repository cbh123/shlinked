defmodule Shlinkedin.Repo.Migrations.AddOwnerIdToAds do
  use Ecto.Migration

  def change do
    alter table(:ads) do
      add(:owner_id, references(:profiles, on_delete: :nothing))
    end

    create(index(:ads, [:owner_id]))
  end
end
