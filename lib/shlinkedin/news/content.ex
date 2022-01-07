defmodule Shlinkedin.News.Content do
  use Ecto.Schema
  import Ecto.Changeset

  schema "content" do
    field :author, :string
    field :content, :string
    field :twitter, :string
    field :header_image, :string
    field :title, :string
    field :subtitle, :string
    field :tags, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(content, attrs) do
    content
    |> cast(attrs, [:author, :content, :twitter, :header_image, :title, :subtitle, :tags])
    |> validate_required([:author, :content, :header_image, :title])
  end
end
