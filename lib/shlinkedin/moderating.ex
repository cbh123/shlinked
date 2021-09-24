defmodule Shlinkedin.Moderating do
  @moduledoc """
  The Moderating context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Moderating.Moderator
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles

  @doc """
  Gets moderating powers.
  """
  def get_moderator_powers(%Moderator{profile_id: profile_id}) do
    mod = Repo.get_by(Moderator, profile_id: profile_id)

    if is_nil(mod) do
      []
    else
    end
  end

  def mod_powers() do
  end

  @doc """
  # Current mod powers (9/18/21):
  - Edit: edit any post, headline, comment, profile, anything.
  - Delete: delete any post, headline, comment, profile, etc.
  - Censor: stop anything from being visible.
  """
  def list_mod_powers() do
    [:edit, :delete, :censor]
  end

  @doc """
  Creates a moderator for given profile. Requires granter profile
  to make sure they have right permissions.

  ## Examples

      iex> create_moderator(%Profile{}, %Profile{}, %{field: value})
      {:ok, %Moderator{}}

      iex> create_moderator(%Profile{}, %Profile{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_moderator(%Profile{} = granter, %Profile{id: profile_id}, attrs \\ %{}) do
    %Moderator{id: profile_id}
    |> Moderator.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Updates a moderator.

  ## Examples

      iex> update_moderator(moderator, %{field: new_value})
      {:ok, %Moderator{}}

      iex> update_moderator(moderator, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_moderator(%Moderator{} = moderator, attrs) do
    moderator
    |> Moderator.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a moderator.

  ## Examples

      iex> delete_moderator(moderator)
      {:ok, %Moderator{}}

      iex> delete_moderator(moderator)
      {:error, %Ecto.Changeset{}}

  """
  def delete_moderator(%Moderator{} = moderator) do
    Repo.delete(moderator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking moderator changes.

  ## Examples

      iex> change_moderator(moderator)
      %Ecto.Changeset{data: %Moderator{}}

  """
  def change_moderator(%Moderator{} = moderator, attrs \\ %{}) do
    Moderator.changeset(moderator, attrs)
  end

  def profile_power(%Profile{id: profile_id}) do
    profile = Profiles.get_profile_by_profile_id(profile_id)
  end
end
