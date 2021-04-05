defmodule Shlinkedin.Repo.Migrations.CommentToText do
  use Ecto.Migration

  def change do
    alter table :comments do
      modify :body, :text
  end
  end
end
