defmodule Shlinkedin.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :from_name, :string
      add :like_type, :string
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end

    create index(:likes, [:profile_id])
    create index(:likes, [:post_id])
  end
end
