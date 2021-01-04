defmodule Shlinkedin.Repo.Migrations.CreateAds do
  use Ecto.Migration

  def change do
    create table(:ads) do
      add :body, :text
      add :media_url, :string
      add :slug, :string
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:ads, [:profile_id])
  end
end
