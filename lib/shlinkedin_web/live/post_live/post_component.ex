defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline.Post

  def handle_event("show-like-options", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: true)

    {:noreply, socket}
  end

  def handle_event("show-potion-options", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_potion_options: true)

    {:noreply, socket}
  end

  def handle_event("expand-post", _, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, expand_post: true)

    {:noreply, socket}
  end

  def handle_event("toggle-post-options", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_post_options: !socket.assigns.show_post_options
    )

    {:noreply, socket}
  end

  def handle_event("hide-post-options", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_post_options: false
    )

    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_like(socket.assigns.profile, socket.assigns.post, like_type)

    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_like_options: false,
      spin: true
    )

    send_update_after(
      PostComponent,
      [id: socket.assigns.post.id, spin: false],
      1000
    )

    {:noreply, socket}
  end

  def handle_event("delete-like", _, socket) do
    Shlinkedin.Timeline.delete_like(socket.assigns.profile, socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("like-cancelled", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: false)
    {:noreply, socket}
  end

  def handle_event("potion-cancelled", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_potion_options: false)
    {:noreply, socket}
  end

  def show_unique_likes(%Post{} = post) do
    Enum.map(post.likes, fn x -> x.like_type end) |> Enum.uniq()
  end

  def like_map_list(like_map) do
    Enum.map(like_map, fn {_, d} -> d end)
  end
end
