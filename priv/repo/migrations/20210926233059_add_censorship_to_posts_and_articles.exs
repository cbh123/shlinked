defmodule Shlinkedin.Repo.Migrations.AddCensorshipToPostsAndArticles do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:removed, :boolean, default: false)
    end

    alter table(:articles) do
      add(:removed, :boolean, default: false)
    end
  end
end
