defmodule Shlinkedin.Repo.Migrations.AddLastReadToConversationMembers do
  use Ecto.Migration

  def change do

    alter table :chat_conversation_members do
      add :last_read, :naive_datetime
    end
  end
end
