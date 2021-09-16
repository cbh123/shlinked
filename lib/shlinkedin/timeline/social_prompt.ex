defmodule Shlinkedin.Timeline.SocialPrompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_prompts" do
    field :active, :boolean, default: true
    field :text, :string
    field :hashtags, :string, default: "shlinkedin"
    field :via, :string, default: "shlinkedin"

    timestamps()
  end

  @doc false
  def changeset(social_prompt, attrs) do
    social_prompt
    |> cast(attrs, [:hashtags, :via, :text, :active])
    |> validate_required([:hashtags, :via, :text, :active])
  end
end
