defmodule Shlinkedin.Points do
  @moduledoc """
  The Points context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Points.Transaction
  alias Shlinkedin.Profiles.Profile

  @doc """
  Checks whether transaction is valid, aka whether or "from profile" can
  pay "to profile" the transaction amount.
  """
  def valid_transaction(%Transaction{from_profile_id: from_profile_id} = transaction) do
    case get_balance(%Profile{id: from_profile_id}) >= transaction.amount do
      true -> {:ok, transaction}
      false -> {:error, "Balance is not large enough."}
    end
  end

  def get_balance(%Profile{} = profile) do
    profile.points
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(%Profile{} = profile) do
    Repo.all(
      from t in Transaction,
        where: t.from_profile_id == ^profile.id or t.to_profile_id == ^profile.id
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
    |> Repo.insert()
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
