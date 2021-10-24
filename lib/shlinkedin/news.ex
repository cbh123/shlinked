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
  alias Shlinkedin.Points

  def censor_article(%Article{} = article) do
    article
    |> Article.changeset(%{removed: true})
    |> Repo.update()
  end

  def uncensor_article(%Article{} = article) do
    article
    |> Article.changeset(%{removed: false})
    |> Repo.update()
  end

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles(criteria, headline_options) when is_list(criteria) do
    query = headline_options |> get_headline_query() |> viewable_articles_query()

    paged_query = paginate(query, criteria)

    from(p in paged_query, preload: :votes)
    |> Repo.all()
    |> parse_results(headline_options)
  end

  defp parse_results(articles, %{type: "reactions"}) do
    Enum.map(articles, fn {_likes, article} -> article end)
  end

  defp parse_results(articles, _), do: articles

  defp get_headline_query(%{type: type, time: time}) do
    time_in_seconds = Shlinkedin.Helpers.parse_time(time)

    case type do
      "new" ->
        from(h in Article, order_by: [desc: h.id])

      "reactions" ->
        time =
          NaiveDateTime.utc_now()
          |> NaiveDateTime.add(time_in_seconds, :second)

        from(h in Article,
          where: h.inserted_at >= ^time,
          left_join: l in assoc(h, :votes),
          group_by: h.id,
          order_by: fragment("count DESC"),
          order_by: [desc: h.id],
          select: {count(l.profile_id, :distinct), h}
        )
    end
  end

  defp viewable_articles_query(query) do
    from a in query, where: a.removed == false
  end

  defp paginate(query, criteria) do
    Enum.reduce(criteria, query, fn {:paginate, %{page: page, per_page: per_page}}, query ->
      from(q in query, offset: ^((page - 1) * per_page), limit: ^per_page)
    end)
  end

  def list_unique_article_votes(%Profile{} = profile) do
    Repo.all(
      from(a in Article,
        where: a.profile_id == ^profile.id,
        join: v in Vote,
        on: a.id == v.article_id,
        group_by: [v.profile_id, v.article_id],
        select: %{profile_id: v.profile_id, article_id: v.article_id}
      )
    )
  end

  def list_unique_article_votes(%Profile{} = profile, start_date) do
    Repo.all(
      from(a in Article,
        where: a.profile_id == ^profile.id,
        join: v in Vote,
        on: a.id == v.article_id,
        where: v.inserted_at >= ^start_date,
        group_by: [v.profile_id, v.article_id],
        select: %{profile_id: v.profile_id, article_id: v.article_id}
      )
    )
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

  def is_first_vote_on_article?(nil, %Article{}) do
    true
  end

  def is_first_vote_on_article?(%Profile{} = profile, %Article{} = article) do
    Repo.one(
      from(v in Vote,
        where: v.article_id == ^article.id and v.profile_id == ^profile.id,
        select: count(v.profile_id)
      )
    ) == 1
  end

  def count_articles(%Profile{} = profile) do
    Repo.aggregate(from(a in Article, where: a.profile_id == ^profile.id), :count)
  end

  def delete_vote(%Profile{} = profile, %Article{} = article) do
    Repo.one(from(v in Vote, where: v.article_id == ^article.id and v.profile_id == ^profile.id))
    |> Repo.delete()

    # could be optimized
    article = get_article_preload_votes!(article.id)
    article_writer = Shlinkedin.Profiles.get_profile_by_profile_id(article.profile_id)

    # subtract points
    Points.point_observer(profile, article_writer, :unvote, article)

    broadcast({:ok, article}, :article_updated)
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
    do: Repo.one(from(a in Article, where: a.id == ^id, preload: :votes))

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

    Points.generate_wealth(profile, :new_headline)

    article
    |> Article.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  def list_votes(%Article{} = article) do
    Repo.all(
      from(v in Vote,
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

  defp broadcast({:ok, article}, event) do
    Phoenix.PubSub.broadcast(Shlinkedin.PubSub, "articles", {event, article})
    {:ok, article}
  end
end
