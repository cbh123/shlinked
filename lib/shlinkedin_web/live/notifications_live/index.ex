defmodule ShlinkedinWeb.NotificationLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  @impl true
  def mount(_params, session, socket) do
    # KNOWN BUG: RIGHT WHEN YOU CREATE AN ACCOUNT, THIS BUTTON DOESN"T WORK! PROBLABLY NOT LOADED INTO SOCKET!
    socket = is_user(session, socket)

    profile = socket.assigns.profile

    notifications = Profiles.list_notifications(profile.id)
    Profiles.update_last_read_notification(profile.id)

    {:ok,
     socket
     |> assign(
       notifications: notifications,
       unread_count: Profiles.get_unread_notification_count(profile)
     ), temporary_assigns: [notifications: []]}
  end

  @impl true
  def handle_event(
        "notification-click",
        %{
          "id" => id,
          "slug" => slug,
          "type" => type,
          "post-id" => post_id,
          "link" => link,
          "article-id" => article_id
        },
        socket
      ) do
    Profiles.change_notification_to_read(id |> String.to_integer())
    my_slug = socket.assigns.profile.slug

    case type do
      "endorsement" ->
        {:noreply, push_redirect(socket, to: "/sh/#{my_slug}/notifications")}

      "testimonial" ->
        {:noreply, push_redirect(socket, to: "/sh/#{my_slug}/notifications")}

      "jab" ->
        {:noreply, push_redirect(socket, to: "/sh/#{slug}/notifications")}

      "accepted_shlink" ->
        {:noreply, push_redirect(socket, to: "/sh/#{slug}/notifications")}

      "new_profile" ->
        {:noreply, push_redirect(socket, to: "/sh/#{slug}/notifications")}

      "pending_shlink" ->
        {:noreply, push_redirect(socket, to: "/shlinks/notifications")}

      "comment" ->
        {:noreply, push_redirect(socket, to: "/posts/#{post_id}/notifications")}

      "post_tag" ->
        {:noreply, push_redirect(socket, to: "/posts/#{post_id}/notifications")}

      "like" ->
        {:noreply, push_redirect(socket, to: "/posts/#{post_id}/notifications")}

      "featured" ->
        {:noreply, push_redirect(socket, to: "/posts/#{post_id}/notifications")}

      "new_badge" ->
        # ultimately should go to a badge page?
        {:noreply, push_redirect(socket, to: "/sh/#{my_slug}/notifications")}

      "admin_message" ->
        {:noreply, push_redirect(socket, to: if(link == "", do: "/", else: link))}

      "vote" ->
        {:noreply, push_redirect(socket, to: "/news/#{article_id}/votes")}
    end
  end

  def handle_event("mark-all-read", _, socket) do
    Profiles.mark_all_notifications_read(socket.assigns.profile)

    {:noreply,
     socket |> assign(notifications: Profiles.list_notifications(socket.assigns.profile.id))}
  end
end
