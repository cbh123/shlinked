defmodule ShlinkedinWeb.AdminLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles.Notification

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, check_access(socket) |> assign(live_action: socket.assigns.live_action || :index)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :new_notification, _params) do
    socket
    |> assign(:page_title, "Create Notification")
    |> assign(:notification, %Notification{})
  end

  defp apply_action(socket, :new_email, _params) do
    socket
    |> assign(:page_title, "Create Email to EVERYONE!")
    |> assign(:notification, %Notification{})
  end

  defp check_access(socket) do
    case socket.assigns.profile.admin do
      false ->
        socket
        |> put_flash(:danger, "ACCESS DENIED")
        |> push_redirect(to: "/")

      true ->
        socket
    end
  end
end
