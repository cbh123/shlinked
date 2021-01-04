defmodule Shlinkedin.Awards.AwardType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "award_types" do
    field :bg, :string
    field :bg_hover, :string
    field :color, :string, default: "text-blue-500"
    field :description, :string
    field :emoji, :string
    field :fill, :string, default: "even-odd"
    field :image_format, :string, default: "emoji"
    field :name, :string
    field :svg_path, :string
    field :profile_badge, :boolean, default: false
    field :profile_badge_days, :integer, default: 10000

    timestamps()
  end

  @doc false
  def changeset(award_type, attrs) do
    award_type
    |> cast(attrs, [
      :emoji,
      :image_format,
      :description,
      :name,
      :bg,
      :color,
      :bg_hover,
      :fill,
      :svg_path,
      :profile_badge,
      :profile_badge_days
    ])
    |> validate_required([
      :image_format,
      :description,
      :name
    ])
  end
end
