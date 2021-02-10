defmodule Shlinkedin.Repo.Migrations.CreateChatSeenMessages do
  use Ecto.Migration

  def change do
    create table(:chat_seen_messages) do
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :message_id, references(:chat_messages, on_delete: :nothing)

      timestamps()
    end

    create index(:chat_seen_messages, [:profile_id])
    create index(:chat_seen_messages, [:message_id])
  end
end
