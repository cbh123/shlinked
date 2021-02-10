defmodule Shlinkedin.Chat.MessageReaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_message_reactions" do
    field :message_id, :id
    field :profile_id, :id
    field :emoji_id, :id

    timestamps()
  end

  @doc false
  def changeset(message_reaction, attrs) do
    message_reaction
    |> cast(attrs, [])
    |> validate_required([])
  end
end
