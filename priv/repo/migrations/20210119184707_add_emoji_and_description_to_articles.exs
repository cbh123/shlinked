defmodule Shlinkedin.Repo.Migrations.AddEmojiAndDescriptionToArticles do
  use Ecto.Migration

  def change do
    alter table :articles do
      add :key, :string, null: false
      add :unicode, :string, null: false
    end
  end
end
