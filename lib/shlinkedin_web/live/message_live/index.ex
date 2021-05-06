defmodule ShlinkedinWeb.MessageLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.{Profiles, Chat, Repo}
  alias Shlinkedin.Chat.Conversation
  alias Shlinkedin.Groups.Invite

  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(profile: socket.assigns.profile)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :new_message, _params) do
    socket
    |> assign(:page_title, "New ShlinkMail")
    |> assign(:profile, socket.assigns.profile)
    |> assign(:invite, %Invite{})
  end
end
