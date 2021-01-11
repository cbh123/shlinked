defmodule Shlinkedin.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Groups.Group
  alias Shlinkedin.Groups.Member
  alias Shlinkedin.Profiles.Profile

  def is_member?(%Profile{} = profile, %Group{} = group) do
    Repo.one(
      from m in Member,
        where: m.group_id == ^group.id and m.ranking == "member" and m.profile_id == ^profile.id
    ) !=
      nil
  end

  def list_members(%Group{} = group) do
    Repo.all(from m in Member, where: m.group_id == ^group.id and m.ranking == "member")
  end

  @doc """
  Add current profile as a member to given group.
  """
  def join_group(%Profile{} = profile, %Group{} = group, attrs \\ %{}) do
    {:ok, _member} =
      %Member{profile_id: profile.id, group_id: group.id}
      |> Member.changeset(attrs)
      |> Repo.insert()

    Shlinkedin.Profiles.ProfileNotifier.observer(
      {:ok, group},
      :new_group_member,
      profile,
      profile
    )
  end

  def leave_group(%Profile{} = profile, %Group{} = group) do
    IO.inspect(group, label: "")
    IO.inspect(get_member(profile, group), label: "")
    get_member(profile, group) |> Repo.delete()
  end

  def invite_to_group do
  end

  def remove_from_group do
  end

  def request_access do
  end

  def change_member_status do
  end

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

  def get_member(%Profile{} = profile, %Group{} = group) do
    Repo.one(from m in Member, where: m.profile_id == ^profile.id and m.group_id == ^group.id)
  end

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

    # TODO: add creator as founder to members table

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
