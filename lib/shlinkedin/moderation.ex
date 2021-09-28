defmodule Shlinkedin.Moderation do
  @moduledoc """
  The Moderation context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Moderation.Action
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Timeline.{Comment, Post}
  alias Shlinkedin.News.Article
  alias Shlinkedin.News.Article
  alias Shlinkedin.Profiles.{Profile, ProfileNotifier}
  alias Shlinkedin.Profiles

  @doc """
  Returns the list of mod_actions.

  ## Examples

      iex> list_mod_actions()
      [%Action{}, ...]

  """
  def list_mod_actions(%Profile{} = profile) do
    Repo.all(from a in Action, where: a.profile_id == ^profile.id)
  end

  @doc """
  Gets a single action.

  Raises `Ecto.NoResultsError` if the Action does not exist.

  ## Examples

      iex> get_actions!(123)
      %Action{}

      iex> get_actions!(456)
      ** (Ecto.NoResultsError)

  """
  def get_action!(id), do: Repo.get!(Action, id)

  @doc """
  Creates a action.

  ## Examples

      iex> create_actions(Content, %Profile{}, %{field: value})
      {:ok, %Action{}}

      iex> create_actions(Content, %Profile{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_action(content, profile, attrs \\ %{})

  def create_action(%Ad{id: ad_id} = ad, %Profile{} = profile, attrs) do
    if attrs["action"] == "censor" do
      {:ok, _ad} = Shlinkedin.Ads.update_ad(ad, profile, %{removed: true})
    end

    %Action{ad_id: ad_id}
    |> _create_action(profile, attrs)
  end

  def create_action(%Post{id: post_id}, %Profile{} = profile, attrs) do
    %Action{post_id: post_id}
    |> _create_action(profile, attrs)
  end

  def create_action(%Article{id: article_id}, %Profile{} = profile, attrs) do
    %Action{article_id: article_id}
    |> _create_action(profile, attrs)
  end

  # def create_action(%Comment{id: comment_id}, %Profile{} = profile, attrs) do
  #   %Action{comment_id: comment_id}
  #   |> _create_action(profile, attrs)
  # end

  def _create_action(%Action{} = action, %Profile{} = profile, attrs) do
    raise "we need to notify the actual creator of the content"

    result =
      action
      |> Action.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:profile, profile)
      |> Repo.insert()

    notification_type = get_notification_type(result)

    result |> ProfileNotifier.notify(result, notification_type, Profiles.get_god(), profile)
  end

  defp get_notification_type({:error, _changeset}), do: :error

  defp get_notification_type({:ok, %Action{} = action}) do
    cond do
      action.post_id != nil -> :moderated_post
      action.article_id != nil -> :moderated_article
      action.comment_id != nil -> :moderated_comment
      action.ad_id != nil -> :moderated_ad
      true -> :error
    end
  end

  @doc """
  Updates a action.

  ## Examples

      iex> update_actions(action, %{field: new_value})
      {:ok, %Action{}}

      iex> update_actions(action, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_action(%Action{} = action, attrs) do
    action
    |> Action.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a action.

  ## Examples

      iex> delete_actions(action)
      {:ok, %Action{}}

      iex> delete_actions(action)
      {:error, %Ecto.Changeset{}}

  """
  def delete_action(%Action{} = action) do
    Repo.delete(action)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking action changes.

  ## Examples

      iex> change_action(action)
      %Ecto.Changeset{data: %Action{}}

  """
  def change_action(%Action{} = action, attrs \\ %{}) do
    Action.changeset(action, attrs)
  end
end
