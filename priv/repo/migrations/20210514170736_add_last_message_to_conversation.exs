defmodule Shlinkedin.Repo.Migrations.AddLastMessageToConversation do
  use Ecto.Migration

  def change do
    alter table :chat_conversations do
      add :last_message_sent, :naive_datetime
    end
  end
end
