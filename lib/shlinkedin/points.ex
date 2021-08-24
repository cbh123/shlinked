defmodule Shlinkedin.Points do
  @moduledoc """
  The Points context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Points.{Transaction, Statistic}
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.ProfileNotifier
  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.{Post, Comment}

  def rules() do
    %{
      :like => %{
        amount: Money.new(200),
        desc:
          "For each post reaction you receive. You can get max 1 points from 1 person for each post."
      },
      :comment_like => %{
        amount: Money.new(200),
        desc:
          "For each comment reaction you receive. You can get max 1 points from 1 person for each comment."
      },
      :vote => %{
        amount: Money.new(500),
        desc: "For each headline clap you receive"
      },
      :unvote => %{
        amount: Money.new(-500),
        desc: "If someone unclaps your headline"
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
      },
      # :sent_testimonial => %{
      #   amount: Money.new(99),
      #   desc: "For writing a review"
      # },
      :featured_post => %{
        amount: Money.new(5000),
        desc: "For getting a featured post"
      },
      # :see_more => %{
      #   amount: Money.new(99),
      #   desc: "For when someone clicks 'see more' on one of your posts"
      # },
      :ad_click => %{
        amount: Money.new(1000),
        desc: "For when someone clicks on your ad"
      },
      :ad_like => %{
        amount: Money.new(2000),
        desc: "For when someone reacts to your ad"
      },
      :join_discord => %{
        amount: Money.new(10000),
        desc: "For joining the discord"
      }
      # :new_ad => %{
      #   amount: Money.new(-2000),
      #   desc: "For cost of writing an ad."
      # }
    }
  end

  def point_observer(%Profile{} = from_profile, %Profile{} = to_profile, :like, post_like) do
    from_profile
    |> Timeline.is_first_like_on_post?(%Post{id: post_like.post_id})
    |> handle_first_like(to_profile, :like)
  end

  def point_observer(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        :comment_like,
        comment_like
      ) do
    from_profile
    |> Timeline.is_first_like_on_comment?(%Comment{id: comment_like.comment_id})
    |> handle_first_like(to_profile, :comment_like)
  end

  def point_observer(
        %Profile{} = _from_profile,
        %Profile{} = to_profile,
        :vote,
        article
      ) do
    if article.profile_id != to_profile.id do
      generate_wealth(to_profile, :vote)
    else
      {:ok, %Transaction{}}
    end
  end

  def point_observer(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        :unvote,
        article
      ) do
    if article.profile_id != from_profile.id do
      generate_wealth(to_profile, :unvote)
    else
      {:ok, %Transaction{}}
    end
  end

  def point_observer(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        :ad_click,
        ad
      ) do
    if ad.profile_id != from_profile.id do
      generate_wealth(to_profile, :ad_click)
    else
      {:ok, %Transaction{}}
    end
  end

  def point_observer(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        :ad_like,
        ad
      ) do
    if ad.profile_id != from_profile.id do
      generate_wealth(to_profile, :ad_like)
    else
      {:ok, %Transaction{}}
    end
  end

  def point_observer(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        :testimonial,
        testimonial
      ) do
    if testimonial.profile_id != from_profile.id do
      generate_wealth(to_profile, :testimonial)
    else
      {:ok, %Transaction{}}
    end
  end

  def point_observer(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        :endorsement,
        endorsement
      ) do
    if endorsement.from_profile_id != from_profile.id do
      generate_wealth(to_profile, :endorsement)
    else
      {:ok, %Transaction{}}
    end
  end

  def point_observer(
        %Profile{} = from_profile,
        %Profile{} = _to_profile,
        :accepted_friend_request,
        _request
      ) do
    generate_wealth(from_profile, :accepted_friend_request)
  end

  def point_observer(%Profile{} = _from_profile, %Profile{} = to_profile, type, _object) do
    generate_wealth(to_profile, type)
  end

  def point_observer(%Profile{} = to_profile, :join_discord) do
    god = get_god()

    generate_wealth(to_profile, :join_discord)
    |> ProfileNotifier.observer(:sent_transaction, god, to_profile)
  end

  def point_observer(%Profile{} = to_profile, type) do
    generate_wealth(to_profile, type)
  end

  defp handle_first_like(true, to_profile, type), do: generate_wealth(to_profile, type)
  defp handle_first_like(false, _to_profile, _type), do: {:ok, nil}

  def get_rule_amount(type), do: rules()[type].amount
  def get_rule_desc(type), do: rules()[type].desc

  @doc """
  Checks whether transaction is valid, aka whether or "from profile" can
  pay "to profile" the transaction amount.
  """
  def get_balance(%Profile{id: id}) do
    Shlinkedin.Profiles.get_profile_by_profile_id(id).points
  end

  @doc """
  Transfers wealth from one profile to another. Note that it's designed to use
  as part of a changeset, which is why it takes in {:ok, %Transaction{}} and
  returns:

  {:ok, transaction} | {:error, changeset}
  """
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
  def generate_wealth(%Profile{} = profile, type) do
    balance = get_balance(profile)
    amount = get_rule_amount(type)
    new_balance = Money.add(balance, amount)
    note = get_rule_desc(type)

    # update profile
    Shlinkedin.Profiles.update_profile(profile, %{points: new_balance})

    # get god
    god_profile =
      Shlinkedin.Profiles.get_profile_by_username("god")
      |> get_god_profile()

    %Transaction{
      from_profile_id: god_profile.id,
      to_profile_id: profile.id,
      amount: amount,
      note: note
    }
    |> Transaction.changeset(%{})
    |> Repo.insert()
  end

  @doc """
  Generates wealth out of thin air, but takes in an amount rather
  than a rule. *Assumes that a check has already been made that transaction is possible*

  ## Example
  iex> generate_wealth(%Profile{}, %Money{})
  {:ok, %Transaction{}}
  """
  def generate_wealth_given_amount(%Profile{} = profile, %Money{} = money, note) do
    balance = get_balance(profile)
    new_balance = Money.add(balance, money)

    # update profile
    Shlinkedin.Profiles.update_profile(profile, %{points: new_balance})

    # get god
    god_profile = get_god()

    %Transaction{
      from_profile_id: god_profile.id,
      to_profile_id: profile.id,
      amount: money.amount,
      note: note
    }
    |> Transaction.changeset(%{})
    |> Repo.insert()
  end

  defp get_god do
    Shlinkedin.Profiles.get_profile_by_username("god")
    |> get_god_profile()
  end

  defp get_god_profile(nil), do: profile_fixture()
  defp get_god_profile(god), do: god

  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user#{System.unique_integer()}@example.com",
        password: "hello world!"
      })
      |> Shlinkedin.Accounts.register_user()

    user
  end

  defp profile_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user, user_fixture())

    {:ok, profile} =
      Shlinkedin.Profiles.create_profile(
        user,
        attrs
        |> Enum.into(%{
          "persona_name" => "God",
          "slug" => "god",
          "title" => "Ruler of the Universe",
          "username" => "god",
          "points" => 10_000_000
        })
      )

    profile
  end

  @doc """
  Returns the list of transactions where profile is from or to.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(%Profile{} = profile) do
    Repo.all(
      from(t in Transaction,
        where: t.from_profile_id == ^profile.id or t.to_profile_id == ^profile.id,
        order_by: [desc: t.inserted_at],
        limit: 100
      )
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
    _create_transaction(from, to, attrs)
    |> ProfileNotifier.observer(:sent_transaction, from, to)
  end

  def create_transaction_no_notification(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    _create_transaction(from, to, attrs)
  end

  defp _create_transaction(%Profile{} = from, %Profile{} = to, attrs) do
    %Transaction{from_profile_id: from.id, to_profile_id: to.id}
    |> Transaction.changeset(attrs)
    |> Transaction.validate_transaction()
    |> Repo.insert()
    |> transfer_wealth()
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

  @doc """
  Sums total points of all profiles.

  Returns %Money{}
  """
  def get_total_points() do
    Repo.aggregate(Shlinkedin.Profiles.Profile, :sum, :points)
  end

  def calc_sum_increase do
    get_last_two_stats() |> calc_sum_increase()
  end

  def calc_pct_increase do
    get_last_two_stats() |> calc_pct_increase()
  end

  defp calc_sum_increase([now, last]), do: Money.subtract(now, last)
  defp calc_sum_increase(_), do: Money.new(0, :SHLINK)

  defp calc_pct_increase([now, last]),
    do: ((now.amount / last.amount - 1) * 100) |> Float.round(2)

  defp calc_pct_increase(_), do: 0.0

  defp get_last_two_stats() do
    Repo.all(from s in Shlinkedin.Points.Statistic, limit: 2, order_by: [desc: s.inserted_at])
    |> Enum.map(& &1.total_points)
  end

  @doc """
  Creates statistics, called in daily job.
  """
  def create_statistic(attrs \\ %{}) do
    %Statistic{}
    |> Statistic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Used for marketplace navigation.
  """
  def categories do
    [
      %{
        title: "Ads",
        emoji: "📺",
        active: true
      },
      %{
        title: "Upgrades",
        emoji: "⚡",
        active: false
      },
      %{
        title: "Jobs",
        emoji: "🤝",
        active: false
      },
      %{
        title: "Companies",
        emoji: "🏭",
        active: false
      }
    ]
  end
end
