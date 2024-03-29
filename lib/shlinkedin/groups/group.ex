defmodule Shlinkedin.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @username_regex ~r/^(?![_.])(?!.*[_.]{2})[a-z0-9._]+(?<![_.])$/

  schema "groups" do
    field :cover_photo_url, :string
    field :privacy_type, :string, default: "public"
    field :title, :string
    field :about, :string
    field :categories, {:array, :string}
    field :slug, :string
    field :header_bg_color, :string, default: "#FFFFFF"
    field :header_text_color, :string
    field :header_font, :string
    field :bg_color, :string, default: "#f1f5f9"

    belongs_to :profile, Shlinkedin.Profiles.Profile
    has_many(:members, Shlinkedin.Groups.Member, on_delete: :nilify_all)
    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :title,
      :privacy_type,
      :cover_photo_url,
      :about,
      :categories,
      :slug,
      :header_bg_color,
      :header_text_color,
      :header_font,
      :bg_color
    ])
    |> validate_required([:title, :privacy_type])
    |> validate_length(:title, min: 1, max: 100)
    |> validate_length(:about, max: 500)
    |> validate_slug()
  end

  defp validate_slug(changeset) do
    changeset
    |> validate_format(:slug, @username_regex, message: "invalid url -- no special characters!")
    |> validate_length(:slug, min: 3, max: 15)
    |> unique_constraint([:slug])
  end
end
