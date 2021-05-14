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
    field :last_message_sent, :naive_datetime
    timestamps()
  end

  @doc false
  def changeset(conversation, attrs) do
    attrs = sort_profile_ids(attrs)

    conversation
    |> cast(attrs, [:title, :profile_ids, :last_message_sent])
    |> cast_assoc(:conversation_members)
    |> validate_required([:profile_ids])
    |> unique_constraint(:profile_ids)
  end

  defp sort_profile_ids(%{profile_ids: profile_ids} = attrs)
       when is_list(profile_ids) and not is_nil(profile_ids) do
    attrs |> Map.update!(:profile_ids, &Enum.sort(&1))
  end

  defp sort_profile_ids(attrs), do: attrs
end
