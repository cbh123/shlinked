defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.PostComponent

  def handle_event("show-like-options", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: true)
    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_like(socket.assigns.profile, socket.assigns.post, like_type)

    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: false)
    {:noreply, socket}
  end

  def handle_event("like-cancelled", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: false)
    {:noreply, socket}
  end
end
