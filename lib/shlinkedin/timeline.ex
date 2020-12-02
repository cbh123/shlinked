defmodule Shlinkedin.Timeline do
  @moduledoc """
  The Timeline context.
  """
  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline.Comment
  alias Shlinkedin.Accounts.Profile

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(
      from p in Post,
        limit: 5,
        left_join: profile in assoc(p, :profile),
        left_join: comments in assoc(p, :comments),
        left_join: profs in assoc(comments, :profile),
        preload: [:profile, comments: {comments, profile: profs}],
        order_by: [desc: p.id]
    )
  end

  def list_posts_no_preload do
    Repo.all(Post)
  end

  def inc_likes(%Post{id: id}) do
    {1, [post]} =
      from(p in Post,
        where: p.id == ^id,
        select: p
      )
      |> Repo.update_all(inc: [likes_count: 1])

    broadcast(
      {:ok, post |> Repo.preload(:profile) |> Repo.preload(comments: [:profile])},
      :post_updated
    )
  end

  def repost(%Post{id: id}) do
    {1, [post]} =
      from(p in Post,
        where: p.id == ^id,
        select: p
      )
      |> Repo.update_all(inc: [reposts_count: 1])

    broadcast({:ok, post}, :post_updated)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  def get_post_preload_profile(id) do
    from(p in Post,
      where: p.id == ^id,
      select: p,
      preload: [:profile]
    )
    |> Repo.one()
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Profile{} = profile, attrs \\ %{}) do
    %Post{
      profile_id: profile.id
    }
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def create_comment(%Profile{} = profile, %Post{id: post_id}, attrs \\ %{}) do
    %Comment{post_id: post_id, profile_id: profile.id}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def list_comments(%Post{} = post) do
    Repo.all(
      from c in Ecto.assoc(post, :comments),
        order_by: [desc: c.inserted_at],
        preload: [:profile]
    )
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Profile{} = profile, %Post{} = post, attrs) do
    case profile.id == post.profile_id do
      true ->
        post
        |> Post.changeset(attrs)
        |> Repo.update()

      false ->
        {:error, "You can only edit your own posts!"}
    end
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
    |> broadcast(:post_deleted)
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Shlinkedin.PubSub, "posts")
  end

  defp broadcast({:error, _reason} = error, _), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(Shlinkedin.PubSub, "posts", {event, post})
    {:ok, post}
  end
end
