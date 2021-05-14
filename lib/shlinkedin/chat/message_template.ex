defmodule Shlinkedin.Chat.MessageTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "message_templates" do
    field :content, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(message_template, attrs) do
    message_template
    |> cast(attrs, [:content, :type])
    |> validate_required([:content, :type])
  end
end
