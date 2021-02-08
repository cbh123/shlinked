defmodule Shlinkedin.Points.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, Money.Ecto.Amount.Type
    field :note, :string
    field :from_profile_id, :id
    field :to_profile_id, :id

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :note])
    |> validate_required([:amount, :note])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end
end
