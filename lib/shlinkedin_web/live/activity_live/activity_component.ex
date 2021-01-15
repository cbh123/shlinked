defmodule ShlinkedinWeb.ActivityLive.ActivityComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Profiles.Notification
  alias Shlinkedin.Profiles
  alias Shlinkedin.Timeline

  defp render_notification_as_activity(%Notification{to_profile_id: to_profile_id} = notification) do
    to = Profiles.get_profile_by_profile_id(to_profile_id)

    notification.action
    |> String.replace("are", "is")
    |> String.replace(["you", "your"], to.persona_name)
  end

  defp render_notification_target(assigns) do
    ~L"""
    <%= case @activity.type do %>
    <% "comment" -> %>
    <% "new_group_member" -> %><a href="#"
    class="font-medium text-gray-900"><%= Shlinkedin.Groups.get_group!(@activity.group_id).title %></a>
    <% other -> %>other
    <% end %>

    """
  end
end
