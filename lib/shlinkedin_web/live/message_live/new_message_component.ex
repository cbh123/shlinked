defmodule ShlinkedinWeb.MessageLive.NewMessageComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Conversations
  alias Shlinkedin.Chat.Conversation
  alias Shlinkedin.Profiles

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       query: nil,
       result: nil,
       loading: false,
       matches: []
     )}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(matches: Profiles.list_random_friends(assigns.profile, 5))
     |> assign(assigns)}
  end

  def handle_event("new-message", %{"id" => id}, socket) do
    # to_profile = Shlinkedin.Profiles.get_profile_by_profile_id(id)

    conversation_attrs = %{
      "conversation_members" => %{
        "0" => %{"profile_id" => socket.assigns.profile.id},
        "1" => %{"profile_id" => id}
      }
    }

    # if conversation exists, redirect to that. otherwise create new conversation.

    case Shlinkedin.Chat.create_conversation(conversation_attrs) do
      {:ok, %Conversation{id: convo_id}} ->
        IO.puts("will redirect to #{convo_id}")
        {:noreply, socket}

      {:error, err} ->
        IO.puts("error")
    end

    # create a conversation with members being current user and to_profile
    # redirect to new conversation page

    {:noreply, socket}
  end

  @impl true
  def handle_event("suggest", %{"q" => q}, socket) do
    matches = Shlinkedin.Profiles.search_profiles(q)
    {:noreply, assign(socket, matches: matches)}
  end
end
