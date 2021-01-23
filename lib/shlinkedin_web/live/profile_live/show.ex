defmodule ShlinkedinWeb.ProfileLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Comment
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Endorsement
  alias Shlinkedin.Profiles.Testimonial

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    show_profile = Shlinkedin.Profiles.get_profile_by_slug(slug)

    socket = is_user(session, socket)

    # store profile view
    Profiles.create_profile_view(socket.assigns.profile, show_profile)

    {:ok,
     socket
     |> assign(show_profile: show_profile)
     |> assign(
       like_map: Timeline.like_map(),
       comment_like_map: Timeline.comment_like_map(),
       page: 1,
       per_page: 5,
       num_show_comments: 1
     )
     |> assign(live_action: socket.assigns.live_action || :show)
     |> assign(page_title: "Shlinked - " <> show_profile.persona_name)
     |> assign(from_notifications: false)
     |> assign(current_awards: Profiles.list_awards(show_profile))
     |> assign(award_types: Shlinkedin.Awards.list_award_types())
     |> assign(ad_clicks: get_ad_clicks(show_profile))
     |> fetch_posts()
     |> assign(from_profile: socket.assigns.profile)
     |> assign(to_profile: show_profile)
     |> assign(connections: Profiles.get_connections(show_profile))
     |> assign(friend_status: check_between_friend_status(socket.assigns.profile, show_profile))
     |> assign(endorsements: list_endorsements(show_profile.id))
     |> assign(mutual_friends: get_mutual_friends(socket.assigns.profile, show_profile))
     |> assign(testimonials: list_testimonials(show_profile.id)), temporary_assigns: [posts: []]}
  end

  defp fetch_posts(%{assigns: %{show_profile: show_profile, page: page, per_page: per}} = socket) do
    assign(socket,
      posts:
        Timeline.list_posts(show_profile, [paginate: %{page: page, per_page: per}], "profile")
    )
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :from_notifications, _params) do
    socket
    |> assign(:from_notifications, true)
  end

  defp apply_action(socket, :edit_endorsement, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Endorsement")
    |> assign(:endorsement, Profiles.get_endorsement!(id))
  end

  defp apply_action(socket, :edit_testimonial, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Review")
    |> assign(:testimonial, Profiles.get_testimonial!(id))
  end

  defp apply_action(socket, :new_endorsement, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Endorse #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:endorsement, %Endorsement{})
  end

  defp apply_action(socket, :new_testimonial, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Write a review for #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:testimonial, %Testimonial{})
  end

  defp apply_action(socket, :edit_awards, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Grant Award to #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:awards, Shlinkedin.Awards.list_award_types())
    |> assign(:current_awards, Profiles.list_awards(socket.assigns.show_profile))
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
      :grouped_likes,
      Timeline.list_comment_likes(comment)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
    |> assign(:comment, comment)
  end

  defp apply_action(socket, :new_comment, %{"post_id" => id, "reply_to" => username}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reply to #{post.profile.persona_name}'s comment")
    |> assign(:reply_to, username)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_comment, %{"post_id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Comment")
    |> assign(:reply_to, nil)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  defp apply_action(socket, :show_friends, _) do
    friends = Profiles.list_friends(socket.assigns.show_profile)

    socket
    |> assign(:page_title, "#{socket.assigns.show_profile.persona_name}'s Shlinks")
    |> assign(:friends, friends)
  end

  defp apply_action(socket, :show_ad_clicks, _) do
    socket
    |> assign(:page_title, "#{socket.assigns.show_profile.persona_name}'s Ad Clicks")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, socket |> fetch_posts()}
  end

  @impl true
  def handle_event("delete-comment", %{"id" => id}, socket) do
    comment = Timeline.get_comment!(id)
    {:ok, _} = Timeline.delete_comment(comment)

    {:noreply,
     socket
     |> put_flash(:info, "Comment deleted")
     |> push_redirect(to: Routes.profile_show_path(socket, :show, socket.assigns.profile.slug))}
  end

  @impl true
  def handle_event("delete-endorsement", %{"id" => id}, socket) do
    endorsement = Profiles.get_endorsement!(id)
    {:ok, _} = Profiles.delete_endorsement(endorsement)

    {:noreply, assign(socket, :endorsements, list_endorsements(socket.assigns.to_profile.id))}
  end

  @impl true
  def handle_event("delete-testimonial", %{"id" => id}, socket) do
    testimonial = Profiles.get_testimonial!(id)
    {:ok, _} = Profiles.delete_testimonial(testimonial)

    {:noreply, assign(socket, :testimonials, list_testimonials(socket.assigns.to_profile.id))}
  end

  def handle_event("send-friend-request", _, socket) do
    Profiles.send_friend_request(socket.assigns.from_profile, socket.assigns.to_profile)
    status = check_between_friend_status(socket.assigns.profile, socket.assigns.to_profile)

    {:noreply,
     socket
     |> assign(friend_status: status)}
  end

  def handle_event("unfriend", _, socket) do
    Profiles.cancel_friend_request(socket.assigns.from_profile, socket.assigns.to_profile)
    status = check_between_friend_status(socket.assigns.profile, socket.assigns.to_profile)

    {:noreply,
     socket
     |> assign(friend_status: status)}
  end

  def handle_event("jab", _, socket) do
    Profiles.send_jab(socket.assigns.from_profile, socket.assigns.to_profile)

    {:noreply,
     socket
     |> put_flash(:info, "Business Jabbed!")}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch_posts()}
  end

  defp list_endorsements(id) do
    Profiles.list_endorsements(id)
  end

  defp check_between_friend_status(from, to) do
    Profiles.check_between_friend_status(from, to)
  end

  defp list_testimonials(id) do
    Profiles.list_testimonials(id)
  end

  defp get_mutual_friends(from, to) do
    Profiles.get_mutual_friends(from, to)
  end

  defp get_ad_clicks(profile) do
    Shlinkedin.Ads.get_ad_clicks(profile)
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    {:noreply,
     socket
     |> assign(:online_profiles, ShlinkedinWeb.Presence.list("online"))}
  end
end
