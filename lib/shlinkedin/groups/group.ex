defmodule Shlinkedin.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :cover_photo_url, :string
    field :public, :boolean, default: false
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:title, :public, :cover_photo_url])
    |> validate_required([:title, :public, :cover_photo_url])
  end
end
