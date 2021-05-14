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
        convo_length = Chat.get_conversation_length(socket.assigns.conversation)

        {:ok,
         socket
         |> assign(profile: socket.assigns.profile)
         |> assign(convo_length: convo_length)
         |> assign(some_text: false)
         |> assign(limit: @limit)
         |> assign(messages: messages)
         |> push_event("scroll-down", %{
           num_messages: convo_length
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

        {:noreply,
         push_event(socket, "send-message", %{num_messages: socket.assigns.convo_length})}

      {:error, msg} ->
        Logger.error(inspect(msg))
        {:noreply, socket}
    end
  end

  def handle_event("icebreaker", _, socket) do
    random_icebreaker = Chat.get_random_icebreaker()
    {:noreply, push_event(socket, "template-message", %{template: random_icebreaker.content})}
  end

  def handle_event("update_message", %{"message" => %{"content" => content}}, socket)
      when is_nil(content) or content == "" do
    {:noreply, socket |> assign(some_text: false)}
  end

  def handle_event("update_message", %{"message" => %{"content" => _}}, socket) do
    {:noreply, socket |> assign(some_text: true)}
  end

  def handle_info({:new_message, new_message}, socket) do
    updated_messages = socket.assigns[:messages] ++ [new_message]

    {:noreply,
     socket
     |> assign(:messages, updated_messages)
     |> push_event("receive-message", %{num_messages: socket.assigns.convo_length})}
  end

  defp get_templates(count \\ 3) do
    Chat.list_random_templates(count)
  end
end
