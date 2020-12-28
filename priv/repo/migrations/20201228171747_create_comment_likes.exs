defmodule Shlinkedin.Repo.Migrations.CreateCommentLikes do
  use Ecto.Migration

  def change do
    create table(:comment_likes) do
      add :like_type, :string
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :comment_id, references(:comments, on_delete: :nothing)

      timestamps()
    end

    create index(:comment_likes, [:profile_id])
    create index(:comment_likes, [:comment_id])
  end
end
