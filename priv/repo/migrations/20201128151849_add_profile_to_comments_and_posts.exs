defmodule Shlinkedin.Repo.Migrations.AddProfileToCommentsAndPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :profile_id, references(:profiles)
    end

    alter table(:comments) do
      add :profile_id, references(:profiles)
    end
  end
end
