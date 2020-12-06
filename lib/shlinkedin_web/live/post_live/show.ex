defmodule ShlinkedinWeb.PostLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, socket.assigns.live_action)
     |> assign(like_map: Timeline.like_map())
     |> assign(show_like_options: false)
     |> assign(:post, Timeline.get_post_preload_all(id))}
  end
end
