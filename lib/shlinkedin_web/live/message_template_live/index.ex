defmodule ShlinkedinWeb.MessageTemplateLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Chat
  alias Shlinkedin.Chat.MessageTemplate

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
      check_access(socket)
      |> assign(:templates, list_templates())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Message template")
    |> assign(:message_template, Chat.get_message_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Message template")
    |> assign(:message_template, %MessageTemplate{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Templates")
    |> assign(:message_template, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    message_template = Chat.get_message_template!(id)
    {:ok, _} = Chat.delete_message_template(message_template)

    {:noreply, assign(socket, :templates, list_templates())}
  end

  defp list_templates do
    Chat.list_templates()
  end
end
