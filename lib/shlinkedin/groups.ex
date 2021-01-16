defmodule Shlinkedin.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Groups.Group
  alias Shlinkedin.Groups.Invite
  alias Shlinkedin.Groups.Member
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.ProfileNotifier

  def list_profile_group_ids(%Profile{} = profile) do
    Repo.all(from m in Member, where: m.profile_id == ^profile.id, select: m.group_id)
  end

  @doc """
  Gets the text for the invite button.
  """
  def member_status(profile, group) do
    cond do
      is_member?(profile, group) -> "Member"
      is_invited?(profile, group) -> "Invited"
      true -> "Invite"
    end
  end

  def is_member?(%Profile{} = profile, %Group{} = group) do
    Repo.one(
      from m in Member,
        where:
          m.group_id == ^group.id and (m.ranking == "member" or m.ranking == "admin") and
            m.profile_id == ^profile.id
    ) !=
      nil
  end

  def is_invited?(%Profile{} = profile, %Group{} = group) do
    Repo.one(from i in Invite, where: i.group_id == ^group.id and i.to_profile_id == ^profile.id) !=
      nil
  end

  def list_members(%Group{} = group) do
    Repo.all(
      from m in Member,
        where: m.group_id == ^group.id and (m.ranking == "member" or m.ranking == "admin")
    )
  end

  def list_members_as_profile(%Group{} = group) do
    member_profile_ids =
      Repo.all(
        from m in Member,
          where: m.group_id == ^group.id and (m.ranking == "member" or m.ranking == "admin"),
          select: m.profile_id
      )

    Repo.all(from p in Profile, where: p.id in ^member_profile_ids)
  end

  def list_admins(%Group{} = group) do
    Repo.all(
      from m in Member, where: m.group_id == ^group.id and m.ranking == "admin", preload: :profile
    )
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

    {:ok, group}
  end

  def leave_group(%Profile{} = profile, %Group{} = group) do
    get_member(profile, group) |> Repo.delete()
  end

  def get_member_ranking(%Profile{} = profile, %Group{} = group) do
    Repo.one(
      from m in Member,
        where: m.profile_id == ^profile.id and m.group_id == ^group.id,
        select: m.ranking
    )
  end

  def send_invite(%Profile{} = from, %Profile{} = to, %Group{} = group, attrs \\ %{}) do
    %Invite{from_profile_id: from.id, to_profile_id: to.id, group_id: group.id}
    |> Invite.changeset(%{status: "pending"})
    |> Invite.changeset(attrs)
    |> Repo.insert_or_update()
    |> ProfileNotifier.observer(:sent_group_invite, from, to)
  end

  def remove_from_group do
  end

  def request_access do
  end

  def change_member_status do
  end

  def update_member(%Member{} = from_member, %Member{} = member, attrs) do
    if check_permissions(from_member, :update_member) do
      member
      |> Member.changeset(attrs)
      |> Repo.update()
    else
      {:error, "You can only edit your own ads!"}
    end
  end

  def check_permissions(%Member{} = _profile, action) do
    case action do
      :edit -> true
      :update_member -> true
      _ -> false
    end
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

  def list_random_groups(count) do
    Repo.all(from g in Group, order_by: fragment("RANDOM()"), limit: ^count)
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

    res =
      group
      |> Group.changeset(attrs)
      |> Repo.insert()
      |> after_save(after_save)

    case res do
      {:ok, group} ->
        join_group(profile, group, %{ranking: "admin"})

      error ->
        error
    end
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
    member = get_member(profile, group)

    if check_permissions(member, :edit) do
      group
      |> Group.changeset(attrs)
      |> Repo.update()
      |> after_save(after_save)
    else
      {:error, "You do not have permission to do that."}
    end
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

  def change_invite(%Invite{} = invite, attrs \\ %{}) do
    Invite.changeset(invite, attrs)
  end

  defp after_save({:ok, group}, func) do
    {:ok, _group} = func.(group)
  end

  defp after_save(error, _func), do: error
end
