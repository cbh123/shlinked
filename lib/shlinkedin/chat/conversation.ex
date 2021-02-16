defmodule Shlinkedin.Chat.Conversation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Chat.{ConversationMember, Message}

  schema "chat_conversations" do
    field :title, :string
    has_many :conversation_members, ConversationMember
    has_many :conversations, through: [:conversation_members, :conversation]
    has_many :messages, Message
    timestamps()
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:title])
    |> cast_assoc(:conversation_members)
    |> validate_required([])
  end
end
