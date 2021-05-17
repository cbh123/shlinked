defmodule ShlinkedinWeb.MessageLive.NewMessageComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Chat
  alias Shlinkedin.Chat.Conversation
  alias Shlinkedin.Profiles

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       query: nil,
       result: nil,
       loading: false,
       matches: [],
       error: nil
     )}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(matches: Profiles.list_random_friends(assigns.profile, 5))
     |> assign(assigns)}
  end

  @impl true
  def handle_event("suggest", %{"q" => q}, socket) do
    matches = Shlinkedin.Profiles.search_profiles(q)
    {:noreply, assign(socket, matches: matches)}
  end

  def handle_event("new-message", %{"id" => id}, socket) do
    profile_ids = [socket.assigns.profile.id, id]

    profile_ids
    |> Enum.sort()
    |> Enum.map(&to_string/1)
    |> create_or_find_convo?()
    |> redirect_conversation(socket)
  end

  defp create_or_find_convo?(profile_ids) when is_list(profile_ids) do
    case Chat.conversation_exists?(profile_ids) do
      %Conversation{} = convo ->
        {:ok, convo}

      nil ->
        %{
          "conversation_members" => conversation_members_format(profile_ids),
          "profile_ids" => profile_ids
        }
        |> Chat.create_conversation()
    end
  end

  defp redirect_conversation({:ok, %Conversation{id: id}}, socket) do
    {:noreply,
     socket
     |> push_redirect(to: Routes.message_show_path(socket, :show, id))}
  end

  defp conversation_members_format(profile_ids) do
    profile_ids
    |> Enum.with_index()
    |> Enum.map(fn {id, i} -> {to_string(i), %{"profile_id" => id}} end)
    |> Enum.into(%{})
  end
end
