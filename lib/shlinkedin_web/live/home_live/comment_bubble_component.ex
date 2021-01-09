defmodule ShlinkedinWeb.HomeLive.CommentBubbleComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.HomeLive.CommentBubbleComponent
  alias ShlinkedinWeb.HomeLive.PostComponent
  alias Shlinkedin.Timeline.Comment
  alias Shlinkedin.Tagging

  def handle_event("expand-comment", _, socket) do
    send_update(CommentBubbleComponent, id: socket.assigns.comment.id, expand_comment: true)

    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_comment_like(
      socket.assigns.profile,
      socket.assigns.comment,
      like_type
    )

    send_update(PostComponent,
      id: socket.assigns.post.id,
      num_show_comments: socket.assigns.num_show_comments
    )

    {:noreply, socket}
  end

  defp format_tags(body, []) do
    Tagging.format_tags(body, [])
  end

  defp format_tags(body, tags) do
    Tagging.format_tags(body, tags)
  end

  defp show_unique_likes(%Comment{} = comment) do
    Enum.map(comment.likes, fn x -> x.like_type end) |> Enum.uniq()
  end

  defp like_map_list(like_map) do
    Enum.map(like_map, fn {_, d} -> d end)
  end
end
