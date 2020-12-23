defmodule ShlinkedinWeb.PostLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline.Comment
  alias Shlinkedin.Timeline.Story

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    socket = is_user(session, socket)

    # need to pull from params here? or somethign else. how do you refresh child component
    public = true

    {:ok,
     socket
     |> assign(
       page: 1,
       per_page: 5,
       public_feed: public,
       stories: Timeline.list_stories(),
       like_map: Timeline.like_map()
     )
     |> fetch_posts(public), temporary_assigns: [posts: []]}
  end

  defp fetch_posts(%{assigns: %{page: page, per_page: per}} = socket, public) do
    case public do
      true ->
        assign(socket,
          posts: Timeline.list_posts(paginate: %{page: page, per_page: per}),
          public: true
        )

      false ->
        assign(socket,
          posts:
            Timeline.list_friend_posts(socket.assigns.profile,
              paginate: %{page: page, per_page: per}
            ),
          public: false
        )
    end
  end

  def handle_event("public", _, socket) do
    {:noreply, socket |> fetch_posts(true)}
  end

  def handle_event("friend", _, socket) do
    {:noreply, socket |> fetch_posts(false)}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch_posts(socket.assigns.public)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Create a post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :new_story, _params) do
    socket
    |> assign(:page_title, "💥 ShlinkBlast Mission Control")
    |> assign(:story, %Story{})
  end

  defp apply_action(socket, :new_comment, %{"id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Comment")
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  defp apply_action(socket, :show_comments, %{"id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Comment")
    |> assign(:comments, Timeline.list_comments(post))
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  defp apply_action(socket, :show_likes, %{"id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reactions")
    |> assign(
      :likes,
      Timeline.list_likes(post)
      |> Enum.group_by(
        &%{name: &1.name, username: &1.username, photo_url: &1.photo_url, slug: &1.slug}
      )
    )
    |> assign(:post, post)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Home")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, assign(socket, :posts, Timeline.list_posts(socket.assigns.paginate_options))}
  end

  @impl true
  def handle_event("delete_comment", %{"id" => id}, socket) do
    comment = Timeline.get_comment!(id)
    {:ok, _} = Timeline.delete_comment(comment)

    {:noreply,
     socket
     |> put_flash(:info, "Comment deleted")
     |> push_redirect(to: Routes.post_index_path(socket, :index))}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end
end
