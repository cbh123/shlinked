defmodule Shlinkedin.Points do
  @moduledoc """
  The Points context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Points.Transaction
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.ProfileNotifier

  @doc """
  Checks whether transaction is valid, aka whether or "from profile" can
  pay "to profile" the transaction amount.
  """
  def get_balance(%Profile{id: id}) do
    Shlinkedin.Profiles.get_profile_by_profile_id(id).points
  end

  def transfer_wealth(
        {:ok,
         %Transaction{from_profile_id: from, to_profile_id: to, amount: amount} = transaction}
      ) do
    from_profile = Shlinkedin.Profiles.get_profile_by_profile_id(from)
    to_profile = Shlinkedin.Profiles.get_profile_by_profile_id(to)

    from_balance = get_balance(from_profile)
    to_balance = get_balance(to_profile)

    from_new_balance = Money.subtract(from_balance, amount)
    to_new_balance = Money.add(to_balance, amount)

    Shlinkedin.Profiles.update_profile(from_profile, %{points: from_new_balance})
    Shlinkedin.Profiles.update_profile(to_profile, %{points: to_new_balance})

    {:ok, transaction}
  end

  def transfer_wealth({:error, changeset}), do: {:error, changeset}

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(%Profile{} = profile) do
    Repo.all(
      from t in Transaction,
        where: t.from_profile_id == ^profile.id or t.to_profile_id == ^profile.id,
        order_by: [desc: t.inserted_at]
    )
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
    Creates a transaction.

    ## Examples

        iex> create_transaction(%{field: value})
        {:ok, %Transaction{}}

        iex> create_transaction(%{field: bad_value})
        {:error, %Ecto.Changeset{}}

  """
  def create_transaction(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    %Transaction{from_profile_id: from.id, to_profile_id: to.id}
    |> Transaction.changeset(attrs)
    |> Transaction.validate_transaction()
    |> Repo.insert()
    |> transfer_wealth()
    |> ProfileNotifier.observer(:sent_transaction, from, to)
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
