defmodule CuriousMessengerWeb.ConversationLive do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.{Profiles, Chat, Repo}

  def render(assigns) do
    ~L"""
    <div>
      <b>User name:</b> <%= @user.nickname %>
    </div>
    <div>
      <b>Conversation title:</b> <%= @conversation.title %>
    </div>
    <div>
      <%= f = form_for :message, "#", [phx_submit: "send_message"] %>
        <%= label f, :content %>
        <%= text_input f, :content %>
        <%= submit "Send" %>
      </form>
    </div>
    <div>
      <b>Messages:</b>
      <%= for message <- @messages do %>
        <div>
          <b><%= message.user.nickname %></b>: <%= message.content %>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(assigns, socket) do
    {:ok, socket}
  end

  def handle_event(
        "send_message",
        %{"message" => %{"content" => content}},
        %{assigns: %{conversation_id: conversation_id, profile_id: profile_id, profile: profile}} =
          socket
      ) do
    case Chat.create_message(%{
           conversation_id: conversation_id,
           profile_id: profile_id,
           content: content
         }) do
      {:ok, new_message} ->
        new_message = %{new_message | profile: profile}

        Phoenix.PubSub.broadcast!(
          "conversation_#{conversation_id}" |> String.to_atom(),
          :new_message,
          new_message
        )

        updated_messages = socket.assigns[:messages] ++ [new_message]

        {:noreply, socket |> assign(:messages, updated_messages)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_params(
        %{"conversation_id" => conversation_id, "profile_id" => profile_id},
        _uri,
        socket
      ) do
    Phoenix.PubSub.subscribe(Shlinkedin.PubSub, "conversation_#{conversation_id}")

    {:noreply,
     socket
     |> assign(:profile_id, profile_id)
     |> assign(:conversation_id, conversation_id)
     |> assign_records()}
  end

  # A private helper function to retrieve needed records from the DB
  defp assign_records(
         %{assigns: %{profile_id: profile_id, conversation_id: conversation_id}} = socket
       ) do
    profile = Profiles.get_profile_by_profile_id(profile_id)

    conversation =
      Chat.get_conversation!(conversation_id)
      |> Repo.preload(messages: [:profile], conversation_members: [:profile])

    socket
    |> assign(:profile, profile)
    |> assign(:conversation, conversation)
    |> assign(:messages, conversation.messages)
  end

  def handle_info(%{event: "new_message", payload: new_message}, socket) do
    updated_messages = socket.assigns[:messages] ++ [new_message]

    {:noreply, socket |> assign(:messages, updated_messages)}
  end
end
