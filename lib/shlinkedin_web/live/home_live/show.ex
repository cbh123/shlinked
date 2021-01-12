defmodule ShlinkedinWeb.HomeLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Comment

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    socket = is_user(session, socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    post = Timeline.get_post_preload_all(id)

    {:noreply,
     socket
     |> assign(:from_notifications, Map.has_key?(params, "notifications"))
     |> assign(:page_title, socket.assigns.live_action)
     |> assign(like_map: Timeline.like_map())
     |> assign(show_like_options: false)
     |> assign(:post, post)
     |> assign(:page_title, "See #{post.profile.persona_name}'s post on ShlinkedIn")}
  end

  defp apply_action(socket, :show_likes, %{"id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reactions")
    |> assign(
      :grouped_likes,
      Timeline.list_likes(post)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
  end

  defp apply_action(socket, :show_comment_likes, %{"comment_id" => comment_id}) do
    comment = Timeline.get_comment!(comment_id)

    socket
    |> assign(:page_title, "Comment Reactions")
    |> assign(
      :grouped_likes,
      Timeline.list_comment_likes(comment)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
    |> assign(:comment, comment)
  end

  defp apply_action(socket, :new_comment, %{"post_id" => id, "username" => username}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reply to #{post.profile.persona_name}'s comment")
    |> assign(:reply_to, username)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_comment, %{"post_id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Comment")
    |> assign(:reply_to, nil)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, assign(socket, :post, post)}
  end
end
