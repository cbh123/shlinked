defmodule Shlinkedin.Points do
  @moduledoc """
  The Points context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Points.Transaction
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.ProfileNotifier

  def rules() do
    %{
      :like => %{
        amount: Money.new(200),
        desc: "For each post reaction you receive"
      },
      :comment_like => %{
        amount: Money.new(200),
        desc: "For each comment reaction you receive"
      },
      :vote => %{
        amount: Money.new(500),
        desc: "For each headline clap you receive"
      },
      :new_headline => %{
        amount: Money.new(-1000),
        desc: "The cost of writing a headline"
      },
      :profile_view => %{
        amount: Money.new(10),
        desc: "For each profile view (from someone other than you)"
      },
      :accepted_friend_request => %{
        amount: Money.new(500),
        desc: "When someone accepts your Shlink Request"
      },
      # :sent_friend_request => %{
      #   amount: Money.new(-250),
      #   desc: "The cost of sending a Shlink Request"
      # },
      # :sent_endorsement => %{
      #   amount: Money.new(200),
      #   desc: "For writing an endorsement"
      # },
      :endorsement => %{
        amount: Money.new(300),
        desc: "For each endorsement you receieve"
      },
      :testimonial => %{
        amount: Money.new(100),
        desc: "For each review star rating"
      }
      # :sent_testimonial => %{
      #   amount: Money.new(99),
      #   desc: "For writing a review"
      # },
      # :featured_post => %{
      #   amount: Money.new(5000),
      #   desc: "For winning 'Post of the Day'"
      # },
      # :see_more => %{
      #   amount: Money.new(99),
      #   desc: "For when someone clicks 'see more' on one of your posts"
      # },
      # :ad_click => %{
      #   amount: Money.new(1000),
      #   desc: "For when someone clicks on your ad"
      # },
      # :new_ad => %{
      #   amount: Money.new(-2000),
      #   desc: "For cost of writing an ad."
      # }
    }
  end

  def get_rule_amount(type), do: rules()[type].amount
  def get_rule_desc(type), do: rules()[type].desc

  def generate_wealth_given_type(from_profile, to_profile, type) do
    if Map.has_key?(rules(), type) do
      amount = get_rule_amount(type)
      desc = get_rule_desc(type)
      generate_wealth(to_profile, amount, "Reward " <> String.downcase(desc))
    end
  end

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
  Similar to transfer_wealth(), but generates points out of thin
  air instead of transferring from one person to another.
  """
  def generate_wealth(%Profile{} = profile, %Money{} = amount, note) do
    balance = get_balance(profile)
    new_balance = Money.add(balance, amount)
    Shlinkedin.Profiles.update_profile(profile, %{points: new_balance})

    # hardcoded to Dave Business' profile id
    %Transaction{from_profile_id: 3, to_profile_id: profile.id, amount: amount, note: note}
    |> Transaction.changeset(%{})
    |> Repo.insert()
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
