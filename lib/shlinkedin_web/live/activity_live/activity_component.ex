defmodule ShlinkedinWeb.ActivityLive.ActivityComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Profiles.Notification
  alias Shlinkedin.Profiles

  defp render_notification_as_activity(%Notification{to_profile_id: to_profile_id} = notification) do
    to = Profiles.get_profile_by_profile_id(to_profile_id)

    notification.action
    |> String.replace("are", "is")
    |> String.replace("has", "")
    |> String.replace("!", "")
    |> String.replace(":", "")
    |> String.replace(["you", "your"], to.persona_name)
    |> render_endorsements(notification)
  end

  defp render_endorsements(text, %Notification{} = notification) do
    case notification.type do
      "endorsement" ->
        text <> " \"#{notification.body}\""

      "new_group_member" ->
        group = Shlinkedin.Groups.get_group!(notification.group_id)

        "joined " <> group.title

      _ ->
        text
    end
  end
end
