defmodule Shlinkedin.Feedback.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedback" do
    field :body, :string
    field :category, :string
    field :from_email, :string
    timestamps()
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:category, :body])
    |> validate_required([:category, :body])
  end
end
