defmodule Shlinkedin.News do
  @moduledoc """
  The News context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.News.Article
  alias Shlinkedin.News.Vote
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.ProfileNotifier

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles() do
    Repo.all(from h in Article, order_by: [desc: h.inserted_at], preload: :votes)
  end

  def list_top_articles(count) do
    Repo.all(from h in Article, order_by: [desc: h.inserted_at], limit: ^count, preload: :votes)
  end

  def list_random_articles(count) do
    query = from(h in Article, order_by: fragment("RANDOM()"), limit: ^count)

    from(h in query,
      preload: [:votes]
    )
    |> Repo.all()
  end

  def create_vote(%Profile{} = profile, %Article{} = article) do
    article_writer = Shlinkedin.Profiles.get_profile_by_profile_id(article.profile_id)

    {:ok, _vote} =
      %Vote{
        profile_id: profile.id,
        article_id: article.id
      }
      |> Repo.insert()
      |> ProfileNotifier.observer(:vote, profile, article_writer)

    # could be optimized
    article = get_article_preload_votes!(article.id)

    broadcast({:ok, article}, :article_updated)
  end

  def is_first_vote_on_article?(%Profile{} = profile, %Article{} = article) do
    Repo.one(
      from v in Vote,
        where: v.article_id == ^article.id and v.profile_id == ^profile.id,
        select: count(v.profile_id)
    ) == 1
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  def get_article_preload_votes!(id),
    do: Repo.one(from a in Article, where: a.id == ^id, preload: :votes)

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(
        %Profile{} = profile,
        %Article{} = article,
        attrs \\ %{},
        after_save \\ &{:ok, &1}
      ) do
    article = %{article | profile_id: profile.id}

    article
    |> Article.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  def list_votes(%Article{} = article) do
    Repo.all(
      from v in Vote,
        join: p in assoc(v, :profile),
        where: v.article_id == ^article.id,
        group_by: [p.persona_name, p.photo_url, p.slug],
        select: %{
          name: p.persona_name,
          photo_url: p.photo_url,
          count: count(v.id),
          slug: p.slug
        },
        order_by: p.persona_name
    )
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
    |> broadcast(:article_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  defp after_save({:ok, post}, func) do
    {:ok, _post} = func.(post)
  end

  defp after_save(error, _func), do: error

  def subscribe do
    Phoenix.PubSub.subscribe(Shlinkedin.PubSub, "articles")
  end

  defp broadcast({:error, _reason} = error, _), do: error

  defp broadcast({:ok, article}, event) do
    Phoenix.PubSub.broadcast(Shlinkedin.PubSub, "articles", {event, article})
    {:ok, article}
  end
end
