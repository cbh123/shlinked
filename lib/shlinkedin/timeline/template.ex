defmodule Shlinkedin.Timeline.Template do
  use Ecto.Schema
  import Ecto.Changeset

  schema "templates" do
    field :body, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> unique_constraint(:title)
  end
end
