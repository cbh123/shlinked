defmodule Shlinkedin.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Profiles.Endorsement
  alias Shlinkedin.Profiles.Testimonial
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.Friend
  alias Shlinkedin.Profiles.ProfileNotifier
  alias Shlinkedin.Accounts.User

  @doc """
  Returns the list of endorsements.

  ## Examples

      iex> list_endorsements()
      [%Endorsement{}, ...]

  """
  def list_endorsements(id) do
    Repo.all(from e in Endorsement, where: e.to_profile_id == ^id)
  end

  def list_testimonials(id) do
    Repo.all(from e in Shlinkedin.Profiles.Testimonial, where: e.to_profile_id == ^id)
  end

  @doc """
  Gets a single endorsement.

  Raises `Ecto.NoResultsError` if the Endorsement does not exist.

  ## Examples

      iex> get_endorsement!(123)
      %Endorsement{}

      iex> get_endorsement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_endorsement!(id), do: Repo.get!(Endorsement, id)

  def get_testimonial!(id), do: Repo.get!(Testimonial, id)

  def get_friend_request!(%Profile{} = from, %Profile{} = to) do
    case Repo.one(
           from f in Friend,
             where:
               (f.from_profile_id == ^from.id and f.to_profile_id == ^to.id) or
                 (f.from_profile_id == ^to.id and f.to_profile_id == ^from.id)
         ) do
      nil -> %Friend{from_profile_id: from.id, to_profile_id: to.id}
      friend -> friend
    end
  end

  @doc """
  Creates a endorsement.

  ## Examples

      iex> create_endorsement(%{field: value})
      {:ok, %Endorsement{}}

      iex> create_endorsement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_endorsement(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    %Endorsement{from_profile_id: from.id, to_profile_id: to.id}
    |> Endorsement.changeset(attrs)
    |> Repo.insert()
    |> ProfileNotifier.observer(from, to, :endorsement)
  end

  def create_testimonial(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    %Testimonial{from_profile_id: from.id, to_profile_id: to.id}
    |> Testimonial.changeset(attrs)
    |> Repo.insert()
    |> ProfileNotifier.observer(from, to, :testimonial)
  end

  def send_friend_request(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    friend = get_friend_request!(from, to)

    friend
    |> Friend.changeset(%{status: "pending"})
    |> Friend.changeset(attrs)
    |> Repo.insert_or_update()
    |> ProfileNotifier.observer(from, to, :sent_friend_request)
  end

  def cancel_friend_request(%Profile{} = from, %Profile{} = to) do
    request = get_friend_request!(from, to)

    request
    |> Friend.changeset(%{status: nil})
    |> Repo.update()
  end

  def accept_friend_request(%Profile{} = from, %Profile{} = to) do
    request = get_friend_request!(from, to)

    request
    |> Friend.changeset(%{status: "accepted"})
    |> Repo.update()
    |> ProfileNotifier.observer(from, to, :accepted_friend_request)
  end

  def check_friend_status(%Profile{} = from, %Profile{} = to) do
    Repo.one(
      from f in Friend,
        select: f.status,
        where: f.from_profile_id == ^from.id and f.to_profile_id == ^to.id
    )
  end

  def get_pending_requests(%Profile{} = to) do
    Repo.all(
      from f in Friend,
        where: f.to_profile_id == ^to.id and f.status == "pending",
        preload: [:profile]
    )
  end

  def get_connections(%Profile{} = profile) do
    Repo.all(
      from f in Friend,
        where:
          (f.to_profile_id == ^profile.id or f.from_profile_id == ^profile.id) and
            f.status == "accepted",
        join: p in Profile,
        as: :profile,
        on: f.from_profile_id == p.id,
        join: p2 in Profile,
        as: :to_profile,
        on: f.to_profile_id == p2.id,
        select: [p, p2]
    )
    |> List.flatten()
    |> Enum.reject(fn p -> p.id == profile.id end)
  end

  def check_between_friend_status(%Profile{} = from, %Profile{} = to) do
    Repo.all(
      from f in Friend,
        select: f.status,
        where:
          f.from_profile_id == ^from.id or f.to_profile_id == ^to.id or
            (f.from_profile_id == ^to.id or f.to_profile_id == ^from.id)
    )
  end

  @doc """
  Updates a endorsement.

  ## Examples

      iex> update_endorsement(endorsement, %{field: new_value})
      {:ok, %Endorsement{}}

      iex> update_endorsement(endorsement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_endorsement(%Endorsement{} = endorsement, attrs) do
    endorsement
    |> Endorsement.changeset(attrs)
    |> Repo.update()
  end

  def update_testimonial(%Testimonial{} = testimonial, attrs) do
    testimonial
    |> Testimonial.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a endorsement.

  ## Examples

      iex> delete_endorsement(endorsement)
      {:ok, %Endorsement{}}

      iex> delete_endorsement(endorsement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_endorsement(%Endorsement{} = endorsement) do
    Repo.delete(endorsement)
  end

  def delete_testimonial(%Testimonial{} = testimonial) do
    Repo.delete(testimonial)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking endorsement changes.

  ## Examples

      iex> change_endorsement(endorsement)
      %Ecto.Changeset{data: %Endorsement{}}

  """
  def change_endorsement(%Endorsement{} = endorsement, attrs \\ %{}) do
    Endorsement.changeset(endorsement, attrs)
  end

  def change_testimonial(%Testimonial{} = testimonial, attrs \\ %{}) do
    Testimonial.changeset(testimonial, attrs)
  end

  def get_random_profiles(count) do
    Repo.all(
      from p in Profile,
        select: %{name: p.persona_name, slug: p.slug, photo: p.photo_url, title: p.persona_title},
        order_by: fragment("RANDOM()"),
        limit: ^count,
        where: not ilike(p.persona_name, "%test%") and not like(p.persona_name, "")
    )
  end

  def get_profile_by_user_id(user_id) do
    from(p in Profile, where: p.user_id == ^user_id, select: p) |> Repo.one()
  end

  def get_profile_by_profile_id(profile_id) do
    from(p in Profile, where: p.id == ^profile_id, select: p) |> Repo.one()
  end

  def get_profile_by_profile_id_preload_user(profile_id) do
    from(p in Profile, where: p.id == ^profile_id, select: p, preload: [:user]) |> Repo.one()
  end

  def get_profile_by_slug(slug) do
    from(p in Profile, where: p.slug == ^slug, select: p, preload: [:posts]) |> Repo.one()
  end

  def change_profile(%Profile{} = profile, %User{id: user_id}, attrs \\ %{}) do
    Profile.changeset(profile, attrs |> Map.put("user_id", user_id))
  end

  def create_profile(%User{id: user_id}, attrs \\ %{}, after_save \\ &{:ok, &1}) do
    %Profile{}
    |> Profile.changeset(attrs |> Map.put("user_id", user_id))
    |> Ecto.Changeset.put_change(:slug, attrs["username"])
    |> Repo.insert()
    |> after_save(after_save)
  end

  def update_profile(%Profile{} = profile, %User{id: user_id}, attrs, after_save \\ &{:ok, &1}) do
    profile = %{profile | user_id: user_id}

    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  defp after_save({:ok, profile}, func) do
    {:ok, _profile} = func.(profile)
  end

  defp after_save(error, _func), do: error
end
