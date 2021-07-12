defmodule Shlinkedin.Ads.Ad do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ads" do
    field(:body, :string)
    field(:media_url, :string)
    field(:slug, :string)
    belongs_to(:profile, Shlinkedin.Profiles.Profile)
    has_many(:clicks, Shlinkedin.Ads.Click, on_delete: :delete_all)
    has_many(:adlikes, Shlinkedin.Ads.AdLike, on_delete: :delete_all)
    field(:company, :string)
    field(:product, :string)
    field(:overlay, :string)
    field(:gif_url, :string)
    field(:overlay_color, :string)
    field(:removed, :boolean, default: false)
    field(:quantity, :integer, default: 1)
    field(:price, Money.Ecto.Amount.Type, default: "100")

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [
      :body,
      :media_url,
      :slug,
      :company,
      :product,
      :overlay,
      :overlay_color,
      :gif_url,
      :removed,
      :quantity,
      :price
    ])
    |> validate_required([:body, :product, :company])
    |> validate_required_inclusion([:gif_url, :media_url])
    |> validate_length(:body, min: 0, max: 250)
    |> validate_length(:company, max: 50)
    |> validate_length(:product, max: 50)
    |> validate_length(:overlay, max: 50)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:price, greater_than: 0)
  end

  def validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, fn field -> get_field(changeset, field) end),
      do: changeset,
      else:
        add_error(
          changeset,
          hd(fields),
          "Make sure you add either a photo or a gif"
        )
  end
end
