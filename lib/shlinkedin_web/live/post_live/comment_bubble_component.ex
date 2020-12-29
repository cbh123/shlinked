defmodule ShlinkedinWeb.PostLive.CommentBubbleComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.CommentBubbleComponent
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline.Comment

  def handle_event("expand-comment", _, socket) do
    send_update(CommentBubbleComponent, id: socket.assigns.comment.id, expand_comment: true)

    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_comment_like(
      socket.assigns.profile,
      socket.assigns.comment,
      like_type
    )

    send_update(PostComponent,
      id: socket.assigns.post.id,
      num_show_comments: socket.assigns.num_show_comments
    )

    {:noreply, socket}
  end

  defp format_tags(body, []) do
    body
  end

  defp format_tags(body, tags) do
    String.replace(body, tags, fn prof ->
      profile = Shlinkedin.Profiles.get_profile_by_username(prof)

      case profile do
        nil ->
          body

        profile ->
          safe_to_string(
            link("#{prof}",
              to: "/sh/#{profile.slug}",
              class: "text-indigo-600 font-semibold hover:underline cursor-pointer"
            )
          )
      end
    end)
  end

  def show_unique_likes(%Comment{} = comment) do
    Enum.map(comment.likes, fn x -> x.like_type end) |> Enum.uniq()
  end

  def length_unique_user_likes(%Comment{} = comment) do
    uniq = Enum.map(comment.likes, fn x -> x.profile_id end) |> Enum.uniq() |> length

    case uniq do
      1 -> "1 person"
      uniq -> "#{uniq} people"
    end
  end

  def like_map_list(like_map) do
    Enum.map(like_map, fn {_, d} -> d end)
  end
end
