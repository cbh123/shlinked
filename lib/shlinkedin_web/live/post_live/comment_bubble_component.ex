defmodule ShlinkedinWeb.PostLive.CommentBubbleComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.CommentBubbleComponent

  def handle_event("expand-comment", _, socket) do
    send_update(CommentBubbleComponent, id: socket.assigns.comment.id, expand_comment: true)

    {:noreply, socket}
  end
end
