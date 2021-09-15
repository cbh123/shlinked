defmodule Shlinkedin.Timeline.SocialPrompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_prompts" do
    field :active, :boolean, default: true
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(social_prompt, attrs) do
    social_prompt
    |> cast(attrs, [:text, :active])
    |> validate_required([:text, :active])
  end
end
