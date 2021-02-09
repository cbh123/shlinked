defmodule Shlinkedin.Points.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Points.Transaction

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
    |> cast(attrs, [:amount, :note, :from_profile_id, :to_profile_id])
    |> validate_required([:amount, :note, :from_profile_id, :to_profile_id])
    |> validate_not_zero(:amount)
  end

  def validate_not_zero(changeset, _amount) do
    validate_change(changeset, :amount, fn :amount, amount ->
      if Money.zero?(amount) do
        [amount: "Cannot send zero ShlinkPoints."]
      else
        []
      end
    end)
  end

  def validate_transaction(
        %Ecto.Changeset{data: %Transaction{from_profile_id: from_profile_id}} = changeset
      ) do
    validate_change(changeset, :amount, fn :amount, amount ->
      balance = Shlinkedin.Points.get_balance(%Profile{id: from_profile_id})

      if Money.compare(balance, amount) < 0 do
        [amount: "Not enough balance. You have #{balance}."]
      else
        []
      end
    end)
  end
end
