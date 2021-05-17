defmodule Shlinkedin.Chat.ConversationMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_conversation_members" do
    field :owner, :boolean, default: false

    belongs_to :profile, Shlinkedin.Profiles.Profile
    belongs_to :conversation, Shlinkedin.Chat.Conversation

    field :last_read, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(conversation_member, attrs) do
    conversation_member
    |> cast(attrs, [:owner, :profile_id, :last_read])
    |> validate_required([:owner, :profile_id])
    |> unique_constraint(:user, name: :chat_conversation_members_conversation_id_user_id_index)
    |> unique_constraint(:conversation_id, name: :chat_conversation_members_owner)
  end
end
