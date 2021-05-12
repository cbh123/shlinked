defmodule Shlinkedin.Chat.Conversation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Chat.{ConversationMember, Message}

  schema "chat_conversations" do
    field :title, :string
    has_many :conversation_members, ConversationMember
    has_many :conversations, through: [:conversation_members, :conversation]
    has_many :messages, Message
    field :profile_ids, {:array, :integer}, unique: true, null: false
    timestamps()
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:title, :profile_ids])
    |> cast_assoc(:conversation_members)
    |> validate_required([:profile_ids])
    |> unique_constraint(:profile_ids)
  end
end
