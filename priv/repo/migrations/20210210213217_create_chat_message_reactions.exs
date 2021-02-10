defmodule Shlinkedin.Repo.Migrations.CreateChatMessageReactions do
  use Ecto.Migration

  def change do
    create table(:chat_message_reactions) do
      add :message_id, references(:chat_messages, on_delete: :nothing)
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :emoji_id, references(:chat_emojis, on_delete: :nothing)

      timestamps()
    end

    create index(:chat_message_reactions, [:message_id])
    create index(:chat_message_reactions, [:profile_id])
    create index(:chat_message_reactions, [:emoji_id])
  end
end
