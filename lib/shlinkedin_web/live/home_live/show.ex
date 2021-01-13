defmodule ShlinkedinWeb.HomeLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Comment

  @impl true
  def mount(%{"id" => id}, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    post = Timeline.get_post_preload_all(id)

    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(like_map: Timeline.like_map())
     |> assign(comment_like_map: Timeline.comment_like_map())
     |> assign(show_like_options: false)
     |> assign(:post, post)
     |> assign(:page_title, "See #{post.profile.persona_name}'s post on ShlinkedIn")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, params) do
    socket
    |> assign(:from_notifications, Map.has_key?(params, "notifications"))
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

  defp apply_action(socket, :new_comment, %{"id" => id, "reply_to" => username}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reply to #{post.profile.persona_name}'s comment")
    |> assign(:reply_to, username)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
  end

  defp apply_action(socket, :new_comment, _params) do
    socket
    |> assign(:page_title, "Comment")
    |> assign(:reply_to, nil)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, assign(socket, :post, post)}
  end
end
