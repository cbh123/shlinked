defmodule Shlinkedin.Repo.Migrations.CreateChatConversations do
  use Ecto.Migration

  def change do
    create table(:chat_conversations) do
      add :title, :string

      timestamps()
    end

  end
end
