defmodule ShlinkedinWeb.PostLive.BodyComponent do
  use ShlinkedinWeb, :live_component

  def mount(socket) do
    socket = assign(socket, expand_post: false)
    {:ok, socket}
  end

  def handle_event("expand-post", _, socket) do
    {:noreply, socket |> assign(expand_post: true)}
  end

  defp format_tags(body, []) do
    Shlinkedin.Tagging.format_tags(body, [])
  end

  defp format_tags(body, tags) do
    Shlinkedin.Tagging.format_tags(body, tags)
  end
end
