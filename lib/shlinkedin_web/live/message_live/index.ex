defmodule ShlinkedinWeb.MessageLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.{Chat, Repo}

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    Chat.get_unread_count(socket.assigns.profile)

    conversations =
      Chat.list_conversations(socket.assigns.profile)
      |> Repo.preload(conversation_members: [:profile])

    {:ok,
     socket
     |> assign(conversations: conversations)
     |> map_convo_id_to_last_message()
     |> map_convo_id_to_unread()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp map_convo_id_to_last_message(%{assigns: %{conversations: conversations}} = socket) do
    last_message_map =
      conversations
      |> Enum.map(fn c -> {c.id, Chat.get_last_message(c)} end)
      |> Map.new()

    assign(socket, last_message_map: last_message_map)
  end

  defp map_convo_id_to_unread(
         %{assigns: %{conversations: conversations, profile: profile}} = socket
       ) do
    unread_map =
      conversations
      |> Enum.map(fn c -> {c.id, Chat.has_unread?(c, profile)} end)
      |> Map.new()

    assign(socket, unread_map: unread_map)
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
