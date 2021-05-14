defmodule ShlinkedinWeb.MessageLive.Show do
  use ShlinkedinWeb, :live_view
  require Logger

  alias Shlinkedin.{Chat, Repo}
  @limit 100

  def mount(%{"conversation_id" => conversation_id}, session, socket) do
    conversation =
      Chat.get_conversation!(conversation_id)
      |> Repo.preload(conversation_members: [:profile])

    is_user(session, socket)
    |> assign(conversation: conversation)
    |> handle_access()
  end

  defp handle_access(socket) do
    case socket.assigns.profile.id in socket.assigns.conversation.profile_ids do
      true ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(
            Shlinkedin.PubSub,
            "conversation_#{socket.assigns.conversation.id}"
          )
        end

        messages = Chat.list_messages(socket.assigns.conversation, @limit)

        {:ok,
         socket
         |> assign(profile: socket.assigns.profile)
         |> assign(convo_length: Chat.get_conversation_length(socket.assigns.conversation))
         |> assign(limit: @limit)
         |> assign(messages: messages)
         |> push_event("scroll-down", %{
           num_messages: length(messages)
         }), temporary_assigns: [messages: []]}

      false ->
        {:ok,
         socket
         |> put_flash(:error, "ShlinkMail Access Denied")
         |> push_redirect(to: Routes.message_index_path(socket, :index))}
    end
  end

  def handle_event(
        "send_message",
        %{"message" => %{"content" => content}},
        %{assigns: %{conversation: conversation, profile: profile}} = socket
      ) do
    case Chat.create_message(%{
           conversation_id: conversation.id,
           profile_id: profile.id,
           content: content
         }) do
      {:ok, new_message} ->
        new_message = %{new_message | profile: profile}

        Phoenix.PubSub.broadcast(
          Shlinkedin.PubSub,
          "conversation_#{conversation.id}",
          {:new_message, new_message}
        )

        {:noreply, push_event(socket, "send-message", %{})}

      {:error, msg} ->
        Logger.error(inspect(msg))
        {:noreply, socket}
    end
  end

  def handle_info({:new_message, new_message}, socket) do
    updated_messages = socket.assigns[:messages] ++ [new_message]

    {:noreply,
     socket |> assign(:messages, updated_messages) |> push_event("receive-message", %{})}
  end
end
