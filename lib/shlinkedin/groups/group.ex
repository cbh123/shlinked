defmodule Shlinkedin.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :cover_photo_url, :string
    field :public, :boolean, default: false
    field :title, :string
    field :bio, :string
    field :categories, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:title, :public, :cover_photo_url, :bio, :categories])
    |> validate_required([:title, :public, :cover_photo_url])
  end
end
