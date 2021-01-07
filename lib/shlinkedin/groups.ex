defmodule Shlinkedin.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Groups.Group
  alias Shlinkedin.Profiles.Profile

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(%Profile{} = profile, %Group{} = group, attrs \\ %{}, after_save \\ &{:ok, &1}) do
    group = %{group | profile_id: profile.id}

    group
    |> Group.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Profile{} = profile, %Group{} = group, attrs, after_save \\ &{:ok, &1}) do
    if check_permissions(profile, group, :edit) do
      group
      |> Group.changeset(attrs)
      |> after_save(after_save)
      |> Repo.update()
    else
      {:error, "You can only edit your own ads!"}
    end
  end

  def check_permissions(%Profile{} = _profile, %Group{} = _group, _action) do
    true
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  defp after_save({:ok, group}, func) do
    {:ok, _group} = func.(group)
  end

  defp after_save(error, _func), do: error
end
