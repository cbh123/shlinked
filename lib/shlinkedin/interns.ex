defmodule Shlinkedin.Interns do
  @moduledoc """
  The Interns context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Interns.Intern
  alias Shlinkedin.Profiles.Profile

  def get_random_intern_name() do
    Shlinkedin.Timeline.Generators.first_name()
  end

  def get_intern_birthyear(intern) do
    Date.add(intern.inserted_at, -intern.age * 365).year
  end

  def get_intern_hunger(intern) do
    time_since_fed = Date.diff(NaiveDateTime.utc_now(), intern.last_fed)

    cond do
      time_since_fed < 2 -> "Full"
      time_since_fed < 5 -> "Hungry"
      time_since_fed < 10 -> "Starving"
      time_since_fed < 10 -> "DYING"
      true -> "PROBABLY DEAD"
    end
  end

  def get_intern_mood(intern) do
    hunger = get_intern_hunger(intern)

    case hunger do
      "Full" -> "Very happy"
      "Hungry" -> "Happy"
      "Starving" -> "Frustrated"
      "DYING" -> "Angry"
      "PROBABLY DEAD" -> "N/A"
      _ -> "N/A"
    end
  end

  @doc """
  Returns the list of interns.

  ## Examples

      iex> list_interns()
      [%Intern{}, ...]

  """
  def list_interns do
    Repo.all(Intern)
  end

  @doc """
  Gets a single intern.

  Raises `Ecto.NoResultsError` if the Intern does not exist.

  ## Examples

      iex> get_intern!(123)
      %Intern{}

      iex> get_intern!(456)
      ** (Ecto.NoResultsError)

  """
  def get_intern!(id), do: Repo.get!(Intern, id)

  @doc """
  Creates a intern.

  ## Examples

      iex> create_intern(%{field: value})
      {:ok, %Intern{}}

      iex> create_intern(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_intern(%Profile{} = profile, attrs \\ %{}) do
    %Intern{}
    |> Intern.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:profile, profile)
    |> Repo.insert()
  end

  @doc """
  Updates a intern.

  ## Examples

      iex> update_intern(intern, %{field: new_value})
      {:ok, %Intern{}}

      iex> update_intern(intern, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_intern(%Intern{} = intern, attrs) do
    intern
    |> Intern.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a intern.

  ## Examples

      iex> delete_intern(intern)
      {:ok, %Intern{}}

      iex> delete_intern(intern)
      {:error, %Ecto.Changeset{}}

  """
  def delete_intern(%Intern{} = intern) do
    Repo.delete(intern)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking intern changes.

  ## Examples

      iex> change_intern(intern)
      %Ecto.Changeset{data: %Intern{}}

  """
  def change_intern(%Intern{} = intern, attrs \\ %{}) do
    Intern.changeset(intern, attrs)
  end
end
