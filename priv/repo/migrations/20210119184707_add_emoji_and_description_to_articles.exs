defmodule Shlinkedin.Repo.Migrations.AddEmojiAndDescriptionToArticles do
  use Ecto.Migration

  def change do
    alter table :articles do
      add :emoji, :string
      add :emoji_description, :string
    end
  end
end
