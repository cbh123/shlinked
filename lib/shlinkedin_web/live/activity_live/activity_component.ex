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
    |> String.replace(["you", "your"], to.persona_name)
  end
end
