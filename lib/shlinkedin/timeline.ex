defmodule Shlinkedin.Timeline do
  @moduledoc """
  The Timeline context.
  """
  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Timeline.{Post, Comment, Like}
  alias Shlinkedin.Accounts.Profile

  def like_map do
    %{
      "Pity" => %{
        like_type: "Pity",
        bg: "bg-indigo-600",
        color: "text-indigo-600",
        bg_hover: "bg-indigo-700",
        fill: "evenodd",
        svg_path:
          "M10 18a8 8 0 100-16 8 8 0 000 16zM7 9a1 1 0 100-2 1 1 0 000 2zm7-1a1 1 0 11-2 0 1 1 0 012 0zm-7.536 5.879a1 1 0 001.415 0 3 3 0 014.242 0 1 1 0 001.415-1.415 5 5 0 00-7.072 0 1 1 0 000 1.415z"
      },
      "Zoop" => %{
        like_type: "Zoop",
        bg: "bg-yellow-500",
        color: "text-yellow-500",
        bg_hover: "bg-yellow-600",
        fill: "",
        svg_path:
          "M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z"
      },
      "Um..." => %{
        like_type: "Um...",
        bg: "bg-red-500",
        color: "text-red-500",
        bg_hover: "bg-red-600",
        fill: "evenodd",
        svg_path:
          "M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z"
      }
    }
  end

  def potion_map do
    %{
      "Mystify" => %{
        potion_type: "Mystify",
        bg: "bg-blue-600",
        color: "text-blue-600",
        bg_hover: "bg-blue-700",
        fill: "evenodd",
        svg_path:
          "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z"
      },
      "Invert" => %{
        potion_type: "Invert",
        bg: "bg-indigo-600",
        color: "text-indigo-600",
        bg_hover: "bg-indigo-700",
        fill: "evenodd",
        svg_path:
          "M10 18a8 8 0 100-16 8 8 0 000 16zM7 9a1 1 0 100-2 1 1 0 000 2zm7-1a1 1 0 11-2 0 1 1 0 012 0zm-7.536 5.879a1 1 0 001.415 0 3 3 0 014.242 0 1 1 0 001.415-1.415 5 5 0 00-7.072 0 1 1 0 000 1.415z"
      },
      "Zap words" => %{
        potion_type: "Zap",
        bg: "bg-yellow-500",
        color: "text-yellow-500",
        bg_hover: "bg-yellow-600",
        fill: "",
        svg_path:
          "M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z"
      },
      "Explode" => %{
        potion_type: "Explode",
        bg: "bg-red-500",
        color: "text-red-500",
        bg_hover: "bg-red-600",
        fill: "evenodd",
        svg_path:
          "M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z"
      }
    }
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(
      from p in Post,
        left_join: profile in assoc(p, :profile),
        left_join: comments in assoc(p, :comments),
        left_join: profs in assoc(comments, :profile),
        preload: [:profile, :likes, comments: {comments, profile: profs}],
        order_by: [desc: p.id],
        limit: 20
    )
  end

  def list_posts_no_preload do
    Repo.all(Post)
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

  def get_post_preload_all(id) do
    Repo.one(
      from p in Post,
        where: p.id == ^id,
        left_join: profile in assoc(p, :profile),
        left_join: comments in assoc(p, :comments),
        left_join: profs in assoc(comments, :profile),
        preload: [:profile, :likes, comments: {comments, profile: profs}],
        order_by: [desc: p.id]
    )
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
  def create_post(
        %Profile{} = profile,
        attrs \\ %{},
        post \\ %Post{},
        after_save \\ &{:ok, &1},
        add_gif \\ false
      ) do
    post = %{post | profile_id: profile.id}

    post = add_gif_url(post, attrs["body"], add_gif)

    post
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
    |> broadcast(:post_created)
  end

  defp add_gif_url(post, _text, add_gif) do
    case add_gif do
      true ->
        post

      false ->
        post
    end
  end

  defp after_save({:ok, post}, func) do
    {:ok, _post} = func.(post)
  end

  defp after_save(error, _func), do: error

  def create_comment(%Profile{} = profile, %Post{id: post_id}, attrs \\ %{}) do
    {:ok, comment} =
      %Comment{post_id: post_id, profile_id: profile.id}
      |> Comment.changeset(attrs)
      |> Repo.insert()

    # simplify this shit
    post =
      Repo.preload(comment, :post).post
      |> Repo.preload(:profile)
      |> Repo.preload(:likes)
      |> Repo.preload(comments: [:profile])

    broadcast(
      {:ok, post},
      :post_updated
    )
  end

  def create_like(%Profile{} = profile, %Post{} = post, like_type) do
    {:ok, like} =
      %Like{
        profile_id: profile.id,
        post_id: post.id,
        like_type: like_type
      }
      |> Repo.insert()

    # simplify this shit
    post =
      Repo.preload(like, :post).post
      |> Repo.preload(:profile)
      |> Repo.preload(:likes)
      |> Repo.preload(comments: [:profile])

    broadcast(
      {:ok, post},
      :post_updated
    )
  end

  def delete_like(%Profile{id: profile_id}, %Post{id: post_id}) do
    {1, [like]} =
      from(l in Like,
        where: l.post_id == ^post_id,
        where: l.profile_id == ^profile_id,
        select: l
      )
      |> Repo.delete_all()

    post =
      Repo.preload(like, :post).post
      |> Repo.preload(:profile)
      |> Repo.preload(:likes)
      |> Repo.preload(comments: [:profile])

    broadcast(
      {:ok, post},
      :post_updated
    )
  end

  def list_comments(%Post{} = post) do
    Repo.all(
      from c in Ecto.assoc(post, :comments),
        order_by: [desc: c.inserted_at],
        preload: [:profile]
    )
  end

  def list_likes(%Post{} = post) do
    Repo.all(
      from c in Ecto.assoc(post, :likes),
        order_by: [desc: c.inserted_at],
        preload: [:profile]
    )
  end

  def list_distinct_likes(%Post{} = post) do
    Repo.all(from l in Ecto.assoc(post, :likes), select: l.like_type, distinct: true)
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Profile{} = profile, %Post{} = post, attrs, after_save \\ &{:ok, &1}) do
    case profile.id == post.profile_id do
      true ->
        post
        |> Post.changeset(attrs)
        |> after_save(after_save)
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
