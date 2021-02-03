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
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
