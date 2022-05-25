defmodule Shlinkedin.Timeline.RewardMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reward_messages" do
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(reward_message, attrs) do
    reward_message
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
