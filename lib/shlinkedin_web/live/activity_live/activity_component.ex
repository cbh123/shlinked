defmodule ShlinkedinWeb.ActivityLive.ActivityComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Profiles.Notification
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile

  defp render_notification_as_activity(%Notification{to_profile_id: to_profile_id} = notification) do
    to = Profiles.get_profile_by_profile_id(to_profile_id)

    notification.action
    |> String.replace("are", "is")
    |> String.replace("has", "")
    |> String.replace("!", "")
    |> String.replace(":", "")
    |> String.replace(["you", "your"], to.persona_name)
    |> render_endorsements(notification)
    |> render_to_profile_link(to)
  end

  defp render_endorsements(text, %Notification{} = notification) do
    case notification.type do
      "endorsement" ->
        text <> " \"#{notification.body}\""

      _ ->
        text
    end
  end

  defp render_to_profile_link(text, %Profile{persona_name: name} = profile) do
    String.replace(
      text,
      name,
      Phoenix.HTML.safe_to_string(
        Phoenix.HTML.Link.link(name,
          to: "/sh/#{profile.slug}",
          class: "font-medium text-gray-900"
        )
      )
    )
  end
end
