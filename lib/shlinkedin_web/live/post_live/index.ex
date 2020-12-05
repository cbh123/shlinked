defmodule ShlinkedinWeb.PostLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline.Comment

  @like_map %{
    "Like" => %{
      like_type: "Like",
      bg: "bg-blue-600",
      color: "text-blue-600",
      bg_hover: "bg-blue-700",
      fill: "",
      svg_path:
        "M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z"
    },
    "Pity Like" => %{
      like_type: "Pity Like",
      bg: "bg-indigo-600",
      color: "text-indigo-600",
      bg_hover: "bg-indigo-700",
      fill: "evenodd",
      svg_path:
        "M10 18a8 8 0 100-16 8 8 0 000 16zM7 9a1 1 0 100-2 1 1 0 000 2zm7-1a1 1 0 11-2 0 1 1 0 012 0zm-7.536 5.879a1 1 0 001.415 0 3 3 0 014.242 0 1 1 0 001.415-1.415 5 5 0 00-7.072 0 1 1 0 000 1.415z"
    },
    "Inspired" => %{
      like_type: "Inspired",
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

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(posts: list_posts())
     |> assign(like_map: @like_map)
     |> assign(liked: false)
     |> assign(show_like_options: false), temporary_assigns: [posts: []]}
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
    |> assign(:likes, Timeline.list_likes(post))
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

    {:noreply, assign(socket, :posts, list_posts())}
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

  defp list_posts do
    Timeline.list_posts()
  end
end
