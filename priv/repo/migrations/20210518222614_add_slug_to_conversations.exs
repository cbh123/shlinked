defmodule Shlinkedin.Repo.Migrations.AddSlugToConversations do
  use Ecto.Migration

  def change do
    alter table :chat_conversations do
      add :slug, :uuid
    end
    create index(:chat_conversations, [:slug])
  end
end
