defmodule Shlinkedin.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline.Comment

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(from p in Post, order_by: [desc: p.id], preload: [:comments])
  end

  def inc_likes(%Post{id: id}) do
    {1, [post]} =
      from(p in Post,
        where: p.id == ^id,
        select: p
      )
      |> Repo.update_all(inc: [likes_count: 1])

    broadcast({:ok, post}, :post_updated)
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

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  def create_comment(%Post{id: post_id}, attrs \\ %{}) do
    %Comment{post_id: post_id}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def list_comments(%Post{} = post) do
    Repo.all(
      from c in Ecto.assoc(post, :comments),
        order_by: [desc: c.inserted_at]
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
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> broadcast(:post_updated)
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

  defp broadcast({:error, _reason} = error), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(Shlinkedin.PubSub, "posts", {event, post})
    {:ok, post}
  end
end
