defmodule Shlinkedin.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :content, :string
    field :conversation_id, :id
    field :profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
