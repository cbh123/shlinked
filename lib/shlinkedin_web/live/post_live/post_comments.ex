defmodule ShlinkedinWeb.PostLive.PostComments do
  use ShlinkedinWeb, :live_component

  def handle_event("expand-comments", _, socket) do
    {:noreply, socket |> assign(num_show_comments: socket.assigns.num_show_comments + 5)}
  end

  def max_show_comments(_post, num_show_comments, nil), do: num_show_comments
  def max_show_comments(post, _num_show_comments, _comment_highlight), do: length(post.comments)
end
