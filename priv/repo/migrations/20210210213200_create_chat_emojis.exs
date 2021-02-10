defmodule Shlinkedin.Repo.Migrations.CreateChatEmojis do
  use Ecto.Migration

  def change do
    create table(:chat_emojis) do
      add :key, :string
      add :unicode, :string

      timestamps()
    end

  end
end
