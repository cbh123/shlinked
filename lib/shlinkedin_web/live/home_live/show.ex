defmodule ShlinkedinWeb.HomeLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Comment

  @impl true
  def mount(%{"id" => id}, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    post = Timeline.get_post_preload_all(id)

    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(like_map: Timeline.like_map())
     |> assign(comment_like_map: Timeline.comment_like_map())
     |> assign(show_like_options: false)
     |> assign(post: post)
     |> assign(meta_attrs: meta_attrs(post.body, post.profile.persona_name))
     |> assign(:page_title, "See #{post.profile.persona_name}'s post on ShlinkedIn")}
  end

  @impl true
  def handle_params(params, _url, %{assigns: %{live_action: :show}} = socket) do
    {:noreply, apply_action(socket, :show, params)}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _url, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply,
         socket
         |> put_flash(:info, "You must join ShlinkedIn to do that :)")
         |> push_patch(to: Routes.home_show_path(socket, :show, id))}

      _user ->
        {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    end
  end

  defp apply_action(socket, :show, params) do
    socket
    |> assign(:from_notifications, Map.has_key?(params, "notifications"))
  end

  defp apply_action(socket, :show_comment_likes, %{"comment_id" => comment_id}) do
    comment = Timeline.get_comment!(comment_id)

    socket
    |> assign(:page_title, "Comment Reactions")
    |> assign(
      :grouped_likes,
      Timeline.list_comment_likes(comment)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
    |> assign(:comment, comment)
  end

  defp apply_action(socket, :show_likes, %{"id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reactions")
    |> assign(
      :grouped_likes,
      Timeline.list_likes(post)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
  end

  defp apply_action(socket, :new_comment, %{"id" => id, "reply_to" => username}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reply to #{post.profile.persona_name}'s comment")
    |> assign(:reply_to, username)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
  end

  defp apply_action(socket, :new_comment, _params) do
    socket
    |> assign(:page_title, "Comment")
    |> assign(:reply_to, nil)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply,
     socket
     |> put_flash(:info, "Post deleted")
     |> push_redirect(to: Routes.home_index_path(socket, :index))}
  end

  @impl true
  def handle_event("delete-comment", %{"id" => id}, socket) do
    comment = Timeline.get_comment!(id)
    {:ok, _} = Timeline.delete_comment(comment)

    {:noreply,
     socket
     |> put_flash(:info, "Comment deleted")
     |> push_redirect(to: Routes.home_show_path(socket, :show, socket.assigns.post.id))}
  end

  @impl true
  def handle_info({:post_created, _post}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, socket |> assign(post: post)}
  end

  @impl true
  def handle_info({:post_deleted, _post}, socket) do
    {:noreply, socket}
  end

  defp meta_attrs(text, name, image \\ "https://shlinked.s3.amazonaws.com/shlinkedin_logo+2.png") do
    trimmed_text = trim_text(text)

    [
      %{
        property: "og:image",
        content:
          "https://og-image-charlop.vercel.app/\"#{trimmed_text}\"**-#{name}**.png?theme=light&md=1&fontSize=100px&images=#{image}"
      },
      %{
        name: "twitter:image:src",
        content:
          "https://og-image-charlop.vercel.app/\"#{trimmed_text}\"**-#{name}**.png?theme=light&md=1&fontSize=100px&images=#{image}"
      },
      %{
        property: "og:image:height",
        content: "1200"
      },
      %{
        property: "og:image:width",
        content: "1200"
      }
    ]
  end

  defp trim_text(text) do
    if String.length(text) <= 70 do
      text
    else
      String.slice(text, 0..70) <> "..."
    end
  end
end
