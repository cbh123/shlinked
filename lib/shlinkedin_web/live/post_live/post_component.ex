defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component

  def handle_event("like", _params, socket) do
    Shlinkedin.Timeline.create_like(socket.assigns.profile, socket.assigns.post, "Deal!")
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    Shlinkedin.Timeline.repost(socket.assigns.post)
    {:noreply, socket}
  end
end
