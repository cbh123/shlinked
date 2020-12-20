defmodule ShlinkedinWeb.PostLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline.Comment

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(
       page: 1,
       per_page: 5,
       random_profiles: Shlinkedin.Profiles.get_random_profiles(5),
       like_map: Timeline.like_map()
     )
     |> fetch_posts(), temporary_assigns: [posts: []]}
  end

  defp fetch_posts(%{assigns: %{page: page, per_page: per}} = socket) do
    assign(socket, posts: Timeline.list_posts(paginate: %{page: page, per_page: per}))
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch_posts()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # page = String.to_integer(params["page"] || "1")
    # per_page = String.to_integer(params["per_page"] || "3")

    # paginate_options = %{page: page, per_page: per_page}
    # posts = Timeline.list_posts(paginate: paginate_options)

    # socket = socket |> assign(posts: posts, options: paginate_options)

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
