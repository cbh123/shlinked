defmodule Shlinkedin.Moderation do
  @moduledoc """
  The Moderation context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Moderation.Action
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Ads
  alias Shlinkedin.Timeline.{Comment, Post}
  alias Shlinkedin.Timeline
  alias Shlinkedin.News
  alias Shlinkedin.News.Article
  alias Shlinkedin.Profiles.{Profile, ProfileNotifier}
  alias Shlinkedin.Profiles

  @doc """
  Returns list of mod actions for a piece of content.
  """
  def list_actions(%Ad{id: ad_id}) do
    Repo.all(from(a in Action, where: a.ad_id == ^ad_id))
  end

  def list_actions(%Post{id: post_id}) do
    Repo.all(from(a in Action, where: a.post_id == ^post_id))
  end

  def list_actions(%Comment{id: comment_id}) do
    Repo.all(from(a in Action, where: a.comment_id == ^comment_id))
  end

  def list_actions(%Article{id: article_id}) do
    Repo.all(from(a in Action, where: a.article_id == ^article_id))
  end

  @doc """
  Deletes all mod actions for a particular piece of content.
  """
  def delete_all(content) do
    list_actions(content)
    |> Enum.each(fn a -> delete_action(a) end)

    uncensor(content)
  end

  defp uncensor(%Post{} = post), do: Timeline.uncensor_post(post)
  defp uncensor(%Ad{} = ad), do: Ads.uncensor_ad(ad)
  defp uncensor(%Article{} = article), do: News.uncensor_article(article)
  defp uncensor(%Comment{} = comment), do: Timeline.uncensor_comment(comment)

  @doc """
  Returns the list of mod_actions.

  ## Examples

      iex> list_mod_actions()
      [%Action{}, ...]

  """
  def list_mod_actions(%Profile{} = profile) do
    Repo.all(from(a in Action, where: a.profile_id == ^profile.id))
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
      {:ok, _ad} = Shlinkedin.Ads.censor_ad(ad)
    end

    %Action{ad_id: ad_id}
    |> _create_action(profile, attrs)
  end

  def create_action(%Post{id: post_id} = post, %Profile{} = profile, attrs) do
    if attrs["action"] == "censor" do
      {:ok, _ad} = Shlinkedin.Timeline.censor_post(post)
    end

    %Action{post_id: post_id}
    |> _create_action(profile, attrs)
  end

  def create_action(%Article{id: article_id} = article, %Profile{} = profile, attrs) do
    if attrs["action"] == "censor" do
      {:ok, _ad} = Shlinkedin.News.censor_article(article)
    end

    %Action{article_id: article_id}
    |> _create_action(profile, attrs)
  end

  # def create_action(%Comment{id: comment_id}, %Profile{} = profile, attrs) do
  #   %Action{comment_id: comment_id}
  #   |> _create_action(profile, attrs)
  # end

  def _create_action(%Action{} = action, %Profile{} = profile, attrs) do
    result =
      action
      |> Action.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:profile, profile)
      |> Repo.insert()

    notification_type = get_notification_type(result)
    owner = get_content_owner(result)

    ProfileNotifier.notify(result, notification_type, Profiles.get_god(), owner)

    result
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

  defp get_content_owner({:error, _changeset}), do: :error

  defp get_content_owner({:ok, %Action{} = action}) do
    cond do
      action.post_id != nil ->
        Timeline.get_post!(action.post_id) |> Repo.preload(:profile) |> Map.get(:profile)

      action.article_id != nil ->
        News.get_article!(action.post_id) |> Repo.preload(:profile) |> Map.get(:profile)

      action.comment_id != nil ->
        Timeline.get_post!(action.post_id) |> Repo.preload(:profile) |> Map.get(:profile)

      action.ad_id != nil ->
        Ads.get_ad!(action.ad_id) |> Repo.preload(:profile) |> Map.get(:profile)

      true ->
        nil
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
