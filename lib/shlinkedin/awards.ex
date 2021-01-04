defmodule Shlinkedin.Awards do
  @moduledoc """
  The Awards context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Awards.AwardType

  @doc """
  Returns the list of award_types.

  ## Examples

      iex> list_award_types()
      [%AwardType{}, ...]

  """
  def list_award_types do
    Repo.all(AwardType)
  end

  @doc """
  Gets a single award_type.

  Raises `Ecto.NoResultsError` if the Award type does not exist.

  ## Examples

      iex> get_award_type!(123)
      %AwardType{}

      iex> get_award_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_award_type!(id), do: Repo.get!(AwardType, id)

  @doc """
  Creates a award_type.

  ## Examples

      iex> create_award_type(%{field: value})
      {:ok, %AwardType{}}

      iex> create_award_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_award_type(attrs \\ %{}) do
    %AwardType{}
    |> AwardType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a award_type.

  ## Examples

      iex> update_award_type(award_type, %{field: new_value})
      {:ok, %AwardType{}}

      iex> update_award_type(award_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_award_type(%AwardType{} = award_type, attrs) do
    award_type
    |> AwardType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a award_type.

  ## Examples

      iex> delete_award_type(award_type)
      {:ok, %AwardType{}}

      iex> delete_award_type(award_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_award_type(%AwardType{} = award_type) do
    Repo.delete(award_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking award_type changes.

  ## Examples

      iex> change_award_type(award_type)
      %Ecto.Changeset{data: %AwardType{}}

  """
  def change_award_type(%AwardType{} = award_type, attrs \\ %{}) do
    AwardType.changeset(award_type, attrs)
  end
end
