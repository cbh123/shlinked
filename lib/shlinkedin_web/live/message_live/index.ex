defmodule ShlinkedinWeb.MessageLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.{Profiles, Chat, Repo, Chat.Conversation}

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    conversations =
      Chat.list_conversations(socket.assigns.profile)
      |> Repo.preload(messages: [:profile], conversation_members: [:profile])

    {:ok,
     socket
     |> assign(conversations: conversations)
     |> assign(profile: socket.assigns.profile)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp get_last_message([]), do: []

  defp get_last_message(m) do
    m = Enum.sort(m, &(&1.inserted_at >= &2.inserted_at))
    [hd | _] = m
    hd.content
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :new_message, _params) do
    socket
    |> assign(:page_title, "New ShlinkMail")
    |> assign(:profile, socket.assigns.profile)
  end
end
