defmodule ShlinkedinWeb.MessageLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.{Profiles, Chat, Repo}
  alias Shlinkedin.Chat.Conversation
  alias Shlinkedin.Groups.Invite
  alias Shlinkedin.Groups

  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    profile =
      Profiles.get_profile_by_user_id_preload_conversations(socket.assigns.current_user.id)

    {:ok,
     socket
     |> assign(profile: profile)
     |> assign_new_conversation_changeset()
     |> assign_contacts(profile)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :invite, %{"id" => id}) do
    socket
    |> assign(:page_title, "Invite to #{socket.assigns.group.title}")
    |> assign(:profile, socket.assigns.profile)
    |> assign(:invite, %Invite{})
    |> assign(:group, Groups.get_group!(id))
  end

  # Build a changeset for the newly created conversation, initially nesting a single conversation
  # member record - the current user - as the conversation's owner.
  #
  # We'll use the changeset to drive a form to be displayed in the rendered template.
  defp assign_new_conversation_changeset(socket) do
    changeset =
      %Conversation{}
      |> Conversation.changeset(%{
        "conversation_members" => [%{owner: true, profile_id: socket.assigns[:current_user].id}]
      })

    assign(socket, :conversation_changeset, changeset)
  end

  # Assign all users as the contact list.
  defp assign_contacts(socket, current_user) do
    profile = Shlinkedin.Profiles.get_profile_by_user_id(current_user.id)
    users = Shlinkedin.Profiles.list_friends(profile)

    assign(socket, :contacts, users)
  end

  def remove_member_link(contacts, user_id, current_user_id) do
    link("#{user_id} #{if user_id == current_user_id, do: "(me)", else: "✖"} ",
      to: "#!",
      phx_click: unless(user_id == current_user_id, do: "remove_member"),
      phx_value_user_id: user_id
    )
  end

  def add_member_link(user) do
    link(user.persona_name,
      to: "#!",
      phx_click: "add_member",
      phx_value_user_id: user.id
    )
  end

  def contacts_except(contacts, current_user) do
    Enum.reject(contacts, &(&1.id == current_user.id))
  end

  def disable_create_button?(assigns) do
    Enum.count(assigns[:conversation_changeset].changes[:conversation_members]) < 2
  end
end
