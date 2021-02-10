defmodule Shlinkedin.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :content, :text
      add :conversation_id, references(:chat_conversations, on_delete: :nothing)
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:chat_messages, [:conversation_id])
    create index(:chat_messages, [:profile_id])
  end
end
