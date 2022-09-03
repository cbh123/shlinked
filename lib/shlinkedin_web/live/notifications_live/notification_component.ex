defmodule ShlinkedinWeb.NotificationLive.NotificationComponent do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        # note: don't actually need to do this. can just pull notification from DB based on id
        "notification-click",
        %{
          "id" => id
        },
        socket
      ) do
    n = Profiles.get_notification!(id)
    Profiles.change_notification_to_read(id |> String.to_integer())
    my_slug = socket.assigns.profile.slug
    n_slug = Shlinkedin.Repo.preload(n, :profile).profile.slug

    case n.type do
      "new_follower" ->
        {:noreply, redirect(socket, to: "/sh/#{n_slug}/notifications")}

      "endorsement" ->
        {:noreply, redirect(socket, to: "/sh/#{my_slug}/notifications")}

      "testimonial" ->
        {:noreply, redirect(socket, to: "/sh/#{my_slug}/notifications")}

      "jab" ->
        {:noreply, redirect(socket, to: "/sh/#{n_slug}/notifications")}

      "accepted_shlink" ->
        {:noreply, redirect(socket, to: "/sh/#{n_slug}/notifications")}

      "new_profile" ->
        {:noreply, redirect(socket, to: "/sh/#{n_slug}/notifications")}

      "pending_shlink" ->
        {:noreply, redirect(socket, to: "/shlinks/notifications")}

      "comment" ->
        {:noreply, redirect(socket, to: "/home/show/posts/#{n.post_id}")}

      "post_tag" ->
        {:noreply, redirect(socket, to: "/home/show/posts/#{n.post_id}")}

      "like" ->
        {:noreply, redirect(socket, to: "/home/show/posts/#{n.post_id}")}

      "featured" ->
        {:noreply, redirect(socket, to: "/home/show/posts/#{n.post_id}")}

      "new_badge" ->
        # ultimately should go to a badge page?
        {:noreply, redirect(socket, to: "/sh/#{my_slug}/notifications")}

      "admin_message" ->
        {:noreply, redirect(socket, to: if(n.link == "", do: "/home", else: n.link))}

      "ad_click" ->
        {:noreply, redirect(socket, to: "/ads/#{n.ad_id}")}

      "ad_like" ->
        {:noreply, redirect(socket, to: "/ads/#{n.ad_id}")}

      "vote" ->
        {:noreply, redirect(socket, to: "/news/#{n.article_id}/votes")}

      "new_group_member" ->
        {:noreply, redirect(socket, to: "/groups/#{n.group_id}")}

      "group_invite" ->
        {:noreply, redirect(socket, to: "/groups/#{n.group_id}")}

      "sent_points" ->
        {:noreply, redirect(socket, to: "/points")}

      "ad_buy" ->
        {:noreply, redirect(socket, to: "/ads/#{n.ad_id}")}

      "devoured_intern" ->
        {:noreply, redirect(socket, to: "/sh/#{n_slug}")}
    end
  end
end
