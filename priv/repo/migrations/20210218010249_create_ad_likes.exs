defmodule Shlinkedin.Repo.Migrations.CreateAdLikes do
  use Ecto.Migration

  def change do
    create table(:ad_likes) do
      add :like_type, :string
      add :ad_id, references(:ads, on_delete: :nothing)
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:ad_likes, [:ad_id])
    create index(:ad_likes, [:profile_id])
  end
end
