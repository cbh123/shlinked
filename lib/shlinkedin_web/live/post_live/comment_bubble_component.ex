defmodule ShlinkedinWeb.PostLive.CommentBubbleComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.CommentBubbleComponent
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline.Comment
  alias Shlinkedin.Tagging

  def handle_event("expand-comment", _, socket) do
    send_update(CommentBubbleComponent, id: socket.assigns.comment.id, expand_comment: true)

    {:noreply, socket}
  end

  def handle_event(
        "show-comment-likes",
        %{"id" => id},
        %{assigns: %{return_to: return_to}} = socket
      ) do
    case return_to do
      "/" -> {:noreply, push_patch(socket, to: "/home/posts/#{id}/comment_likes")}
      other -> {:noreply, push_patch(socket, to: other <> "/posts/#{id}/comment_likes")}
    end
  end

  def handle_event(
        "reply",
        %{"post-id" => id, "username" => username},
        %{assigns: %{return_to: return_to}} = socket
      ) do
    case return_to do
      "/" ->
        {:noreply, push_patch(socket, to: "/home/posts/#{id}/new_comment?reply_to=#{username}")}

      other ->
        {:noreply,
         push_patch(socket, to: other <> "/posts/#{id}/new_comment?reply_to#{username}")}
    end
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
