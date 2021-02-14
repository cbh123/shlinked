defmodule Shlinkedin.Chat.SeenMessage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Chat.Message
  alias Shlinkedin.Profiles.Profile

  schema "chat_seen_messages" do
    belongs_to :profile, Profile
    belongs_to :message, Message

    timestamps()
  end

  @doc false
  def changeset(seen_message, attrs) do
    seen_message
    |> cast(attrs, [:profile_id, :message_id])
    |> validate_required([:profile_id, :message_id])
  end
end
