defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component

  def handle_event("like", _, socket) do
    Shlinkedin.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    Shlinkedin.Timeline.repost(socket.assigns.post)
    {:noreply, socket}
  end
end
