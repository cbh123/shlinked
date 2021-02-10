defmodule Shlinkedin.Chat.SeenMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_seen_messages" do
    field :profile_id, :id
    field :message_id, :id

    timestamps()
  end

  @doc false
  def changeset(seen_message, attrs) do
    seen_message
    |> cast(attrs, [])
    |> validate_required([])
  end
end
