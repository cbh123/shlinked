defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline
  alias Shlinkedin.Tagging
  alias Shlinkedin.Profiles.Profile

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

  def handle_event("feature-post", _params, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)
    poster = Shlinkedin.Profiles.get_profile_by_profile_id(socket.assigns.post.profile_id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        featured: true,
        featured_date: NaiveDateTime.utc_now()
      })
      |> Shlinkedin.Profiles.ProfileNotifier.observer(:featured_post, %Profile{id: 3}, poster)

    socket =
      socket
      |> put_flash(:info, "Post featured!")
      |> push_redirect(to: "/")

    {:noreply, socket}
  end

  def handle_event("unfeature-post", _, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        featured: false
      })

    socket =
      socket
      |> put_flash(:info, "Post un-featured!")
      |> push_redirect(to: "/")

    {:noreply, socket}
  end

  def handle_event("hide-post-options", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_post_options: false
    )

    {:noreply, socket}
  end

  def handle_event("expand-comments", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      num_show_comments: socket.assigns.num_show_comments + 5
    )

    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_like(socket.assigns.profile, socket.assigns.post, like_type)

    send_update(PostComponent,
      id: socket.assigns.post.id,
      spin: true,
      expand_post: true
    )

    send_update_after(
      PostComponent,
      [id: socket.assigns.post.id, spin: false],
      1000
    )

    {:noreply, socket}
  end

  defp format_tags(body, []) do
    Tagging.format_tags(body, [])
  end

  defp format_tags(body, tags) do
    Tagging.format_tags(body, tags)
  end

  defp show_unique_likes(%Post{} = post) do
    Enum.map(post.likes, fn x -> x.like_type end) |> Enum.uniq()
  end

  defp length_unique_user_likes(%Post{} = post) do
    uniq = Enum.map(post.likes, fn x -> x.profile_id end) |> Enum.uniq() |> length

    case uniq do
      1 -> "1 person"
      uniq -> "#{uniq} people"
    end
  end

  defp like_map_list(like_map) do
    Enum.map(like_map, fn {_, d} -> d end)
  end
end
