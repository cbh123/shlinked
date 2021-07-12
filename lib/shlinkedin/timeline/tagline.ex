defmodule Shlinkedin.Timeline.Tagline do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taglines" do
    field :active, :boolean, default: true
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(tagline, attrs) do
    tagline
    |> cast(attrs, [:text, :active])
    |> validate_required([:text])
  end
end
