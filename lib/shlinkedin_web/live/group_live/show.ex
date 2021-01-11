defmodule ShlinkedinWeb.GroupLive.Show do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Groups
  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Post

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket = is_user(session, socket)
    group = Groups.get_group!(id)

    if connected?(socket) do
      Timeline.subscribe()
    end

    {:ok,
     socket
     |> assign(
       group: group,
       page_title: group.title,
       member_status: is_member?(socket.assigns.profile, group),
       members: members(group),
       member_ranking: Shlinkedin.Groups.get_member_ranking(socket.assigns.profile, group),
       page: 1,
       per_page: 5,
       like_map: Timeline.like_map(),
       comment_like_map: Timeline.comment_like_map(),
       num_show_comments: 3
     )
     |> fetch_posts(), temporary_assigns: [posts: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :edit_group, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Group")
    |> assign(:group, Groups.get_group!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Create a post")
    |> assign(:post, %Post{group_id: socket.assigns.group.id})
  end

  defp apply_action(socket, :show_likes, %{"post_id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reactions")
    |> assign(
      :grouped_likes,
      Timeline.list_likes(post)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
  end

  defp apply_action(socket, :show_comment_likes, %{"comment_id" => comment_id}) do
    comment = Timeline.get_comment!(comment_id)

    socket
    |> assign(:page_title, "Comment Reactions")
    |> assign(
      :likes,
      Timeline.list_comment_likes(comment)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
    |> assign(:comment, comment)
  end

  defp fetch_posts(%{assigns: %{page: page, per_page: per, group: group}} = socket) do
    assign(socket,
      posts: Timeline.list_group_posts([paginate: %{page: page, per_page: per}], group)
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch_posts()}
  end

  def handle_event("join-group", %{"id" => id}, socket) do
    group = Groups.get_group!(id)
    Groups.join_group(socket.assigns.profile, group, %{ranking: "member"})

    {:noreply, socket |> assign(member_status: is_member?(socket.assigns.profile, group))}
  end

  @impl true
  def handle_event("leave-group", _, socket) do
    Groups.leave_group(socket.assigns.profile, socket.assigns.group)

    {:noreply,
     socket
     |> put_flash(:info, "You left the group")
     |> push_redirect(to: Routes.group_index_path(socket, :index))}
  end

  defp is_member?(profile, group) do
    Shlinkedin.Groups.is_member?(profile, group)
  end

  defp members(group) do
    Shlinkedin.Groups.list_members(group)
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end
end
