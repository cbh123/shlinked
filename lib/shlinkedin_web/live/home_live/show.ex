defmodule ShlinkedinWeb.HomeLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    socket = is_user(session, socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    post = Timeline.get_post_preload_all(id)

    {:noreply,
     socket
     |> assign(:from_notifications, Map.has_key?(params, "notifications"))
     |> assign(:page_title, socket.assigns.live_action)
     |> assign(like_map: Timeline.like_map())
     |> assign(show_like_options: false)
     |> assign(:post, post)
     |> assign(:page_title, "See #{post.profile.persona_name}'s post on ShlinkedIn")}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, assign(socket, :post, post)}
  end
end
