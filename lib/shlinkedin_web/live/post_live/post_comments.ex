defmodule ShlinkedinWeb.PostLive.PostComments do
  use ShlinkedinWeb, :live_component

  def handle_event("expand-comments", _, socket) do
    {:noreply, socket |> assign(num_show_comments: socket.assigns.num_show_comments + 5)}
  end
end
