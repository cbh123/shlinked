defmodule Shlinkedin.Ads do
  @moduledoc """
  The Ads context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Ads.{Ad, AdLike, Click, Owner}
  alias Shlinkedin.Profiles.{Profile, ProfileNotifier}
  alias Shlinkedin.Profiles
  alias Shlinkedin.Points.Transaction
  alias Shlinkedin.Points

  @doc """
  Buys an Ad. Everytime an ad is bought:
    - check that you don't already own
    - check that you have enough money
      -> if these pass, then:
          - create a transaction to give money to current owner (if no owner, then creator)
    - notify creator that owner bought
    - only allow 3 ad buys per hour
    - send update to component that you own, so buy button goes
  """
  def buy_ad(%Ad{} = ad, %Profile{} = buyer) do
    owner = get_ad_owner(ad)

    with {:ok, _ad} <- check_money(ad, buyer),
         {:ok, _ad} <- check_ownership(ad, buyer),
         {:ok, transaction} <-
           Points.create_transaction_no_notification(buyer, owner, %{
             note: "Ad Purchase",
             amount: ad.price
           }),
         {:ok, _new_owner} <- create_owner(ad, transaction, buyer),
         {:ok, ad} <- ProfileNotifier.observer({:ok, ad}, :ad_buy, buyer, owner) do
      {:ok, ad}
    else
      error -> error
    end
  end

  def check_money(%Ad{price: price} = ad, %Profile{points: points})
      when points.amount >= price.amount,
      do: {:ok, ad}

  def check_money(%Ad{price: price} = ad, %Profile{points: points})
      when points.amount < price.amount,
      do: {:error, "You are too poor"}

  @doc """
  Get all stuff that profile owns.
  TODO
  """

  @doc """
  Check to see if profile already owns ad. A helper for `get_ad_owner\1`.
  """
  def check_ownership(%Ad{} = ad, %Profile{} = profile) do
    if get_ad_owner(ad).id == profile.id do
      {:error, "You cannot own more than 1 of an ad, you greedy capitalist!"}
    else
      {:ok, ad}
    end
  end

  @doc """
  Gets ownership record for ad / profile combination.
  """
  def get_owner_record(%Ad{id: ad_id}, %Profile{id: profile_id}) do
    Repo.one(
      from(o in Owner,
        where: o.ad_id == ^ad_id and o.profile_id == ^profile_id,
        order_by: [desc: o.inserted_at],
        limit: 1
      )
    )
  end

  @doc """
  Creates a new row in the ownership table.
  """
  def create_owner(
        %Ad{id: ad_id},
        %Transaction{id: transaction_id},
        %Profile{id: profile_id},
        attrs \\ %{}
      ) do
    %Owner{ad_id: ad_id, transaction_id: transaction_id, profile_id: profile_id}
    |> Owner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets current ad owner's profile id. Gets the last row of owners table for the ad.
  If there's no record of ownership, the owner is whomever made the ad.
  Note: there can be multiple owners!
  """
  def get_ad_owner(%Ad{} = ad) do
    case Repo.one(
           from(owner in Owner,
             where: owner.ad_id == ^ad.id,
             order_by: [desc: owner.id],
             limit: 1,
             select: owner.profile_id
           )
         ) do
      nil ->
        Profiles.get_profile_by_profile_id(ad.profile_id)

      profile_id ->
        Profiles.get_profile_by_profile_id(profile_id)
    end
  end

  def count_profile_ads(%Profile{} = profile) do
    Repo.aggregate(from(a in Ad, where: a.profile_id == ^profile.id), :count)
  end

  def list_profile_ads(%Profile{} = profile) do
    Repo.all(from(a in Ad, where: a.profile_id == ^profile.id, preload: [:adlikes, :profile]))
  end

  def list_unique_ad_clicks(%Profile{} = profile) do
    Repo.all(
      from(a in Ad,
        where: a.profile_id == ^profile.id,
        join: c in Click,
        on: a.id == c.ad_id,
        group_by: [c.profile_id, c.ad_id],
        select: %{profile_id: c.profile_id, ad_id: c.ad_id}
      )
    )
  end

  def list_unique_ad_clicks(%Profile{} = profile, start_date) do
    Repo.all(
      from(a in Ad,
        where: a.profile_id == ^profile.id,
        join: c in Click,
        on: a.id == c.ad_id,
        where: c.inserted_at >= ^start_date,
        group_by: [c.profile_id, c.ad_id],
        select: %{profile_id: c.profile_id, ad_id: c.ad_id}
      )
    )
  end

  def get_random_ads(num) do
    Repo.all(
      from(a in Ad,
        limit: ^num,
        order_by: fragment("RANDOM()"),
        preload: :profile,
        preload: :adlikes,
        where: not is_nil(a.media_url) or not is_nil(a.gif_url)
      )
    )
  end

  def get_random_ad() do
    Repo.one(
      from(a in Ad,
        limit: 1,
        order_by: fragment("RANDOM()"),
        preload: :profile,
        preload: :adlikes,
        where: a.removed == false
      )
    )
  end

  def get_ad_preload_profile!(id) do
    Repo.one(
      from(a in Ad, where: a.id == ^id, preload: :profile, preload: :clicks, preload: [:adlikes])
    )
  end

  @doc """
  Gets a single ad.

  Raises `Ecto.NoResultsError` if the Ad does not exist.

  ## Examples

      iex> get_ad!(123)
      %Ad{}

      iex> get_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ad!(id), do: Repo.get!(Ad, id)

  @doc """
  Creates a ad.

  ## Examples

      iex> create_ad(%{field: value})
      {:ok, %Ad{}}

      iex> create_ad(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ad(%Profile{} = profile, %Ad{} = ad, attrs \\ %{}, after_save \\ &{:ok, &1}) do
    ad = %{ad | profile_id: profile.id}

    ad
    |> Ad.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  def create_ad_click(%Ad{profile: ad_profile} = ad, %Profile{} = profile, attrs \\ %{}) do
    %Click{ad_id: ad.id, profile_id: profile.id}
    |> Click.changeset(attrs)
    |> Repo.insert()
    |> ProfileNotifier.observer(:ad_click, profile, ad_profile)
  end

  @doc """
  Checks if like on ad count is currently zero, which
  means that the adlike about to be added is first.
  """
  def is_first_like_on_ad?(%Profile{} = profile, %Ad{} = ad) do
    Repo.one(
      from(l in AdLike,
        where: l.ad_id == ^ad.id and l.profile_id == ^profile.id,
        select: count(l.profile_id)
      )
    ) == 0
  end

  def delete_like(%Profile{} = profile, %Ad{} = ad) do
    Repo.one(from(l in AdLike, where: l.ad_id == ^ad.id and l.profile_id == ^profile.id))
    |> Repo.delete()

    # could be optimized
    # ad = get_article_preload_votes!(article.id)

    # broadcast({:ok, article}, :article_updated)
  end

  def get_like_on_ad(%Profile{} = profile, %Ad{} = ad) do
    Repo.one(
      from(l in AdLike,
        where: l.ad_id == ^ad.id and l.profile_id == ^profile.id,
        select: l.like_type
      )
    )
  end

  def create_like(%Profile{} = profile, %Ad{} = ad, like_type) do
    {:ok, _like} =
      %AdLike{
        profile_id: profile.id,
        ad_id: ad.id,
        like_type: like_type
      }
      |> Repo.insert()
      |> ProfileNotifier.observer(:ad_like, profile, ad.profile)
  end

  @doc """
  Updates a ad

  ## Examples

      iex> update_ad(ad, %{field: new_value})
      {:ok, %Ad{}}

      iex> update_ad(ad, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ad(%Ad{} = ad, attrs, after_save \\ &{:ok, &1}) do
    ad
    |> Ad.changeset(attrs)
    |> after_save(after_save)
    |> Repo.update()
  end

  @doc """
  Deletes a ad.

  ## Examples

      iex> delete_ad(ad)
      {:ok, %Ad{}}

      iex> delete_ad(ad)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ad(%Ad{} = ad) do
    Repo.delete(ad)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ad changes.

  ## Examples

      iex> change_ad(ad)
      %Ecto.Changeset{data: %Ad{}}

  """
  def change_ad(%Ad{} = ad, attrs \\ %{}) do
    Ad.changeset(ad, attrs)
  end

  defp after_save({:ok, ad}, func) do
    {:ok, _ad} = func.(ad)
  end

  defp after_save(error, _func), do: error
end
