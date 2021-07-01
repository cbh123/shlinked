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
    |> cast(attrs, [:amount, :note])
    |> validate_length(:note, min: 0, max: 250)
    |> validate_required([:amount, :note])
    |> validate_positive(:amount)
  end

  def validate_positive(changeset, _amount) do
    validate_change(changeset, :amount, fn :amount, amount ->
      if Money.positive?(amount) do
        []
      else
        [amount: "Cannot send zero or negative ShlinkPoints."]
      end
    end)
  end

  @doc """
  Validates that you have enough balance and that you are not sending to yourself.
  """
  def validate_transaction(
        %Ecto.Changeset{
          data: %Transaction{from_profile_id: from_profile_id, to_profile_id: to_profile_id}
        } = changeset
      ) do
    validate_change(changeset, :amount, fn :amount, amount ->
      balance = Shlinkedin.Points.get_balance(%Profile{id: from_profile_id})

      cond do
        Money.compare(balance, amount) < 0 ->
          [amount: "Not enough balance. You have #{balance}."]

        from_profile_id == to_profile_id ->
          [amount: "You cannot send money to yourself, you launderer!"]

        true ->
          []
      end
    end)
  end
end
