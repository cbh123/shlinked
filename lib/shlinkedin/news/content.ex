defmodule Shlinkedin.News.Content do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Profiles

  schema "content" do
    field :author, :string
    field :content, :string
    field :twitter, :string
    field :header_image, :string
    field :title, :string
    field :subtitle, :string
    field :topic, :string
    belongs_to :profile, Shlinkedin.Profiles.Profile
    field :header_image_subtitle, :string
    timestamps()
  end

  @doc false
  def changeset(content, attrs) do
    content
    |> cast(attrs, [
      :author,
      :content,
      :twitter,
      :header_image,
      :title,
      :subtitle,
      :topic,
      :header_image_subtitle
    ])
    |> validate_required([:author, :content, :header_image, :title, :topic])
  end

  def validate_allowed(changeset, profile) do
    case Profiles.is_admin?(profile) do
      true -> changeset
      false -> add_error(changeset, :author, "Only an admin can add content rn.")
    end
  end
end
