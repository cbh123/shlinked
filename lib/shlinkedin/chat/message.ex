defmodule Shlinkedin.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Chat.{Conversation, SeenMessage, MessageReaction}

  schema "chat_messages" do
    field :content, :string

    belongs_to :profile_id, Shlinkedin.Profiles.Profile
    belongs_to :conversation, Conversation

    has_many :seen_messages, SeenMessage
    has_many :message_reactions, MessageReaction

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :conversation_id, :profile_id])
    |> validate_required([:content, :conversation_id, :profile_id])
  end
end
