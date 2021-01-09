defmodule ShlinkedinWeb.PostLive.BodyComponent do
  use ShlinkedinWeb, :live_component

  def handle_event("expand-post", _, socket) do
    send_update(ShlinkedinWeb.PostLive.BodyComponent,
      id: socket.assigns.post.id,
      expand_post: true
    )

    {:noreply, socket}
  end

  defp format_tags(body, []) do
    Shlinkedin.Tagging.format_tags(body, [])
  end

  defp format_tags(body, tags) do
    Shlinkedin.Tagging.format_tags(body, tags)
  end
end
