defmodule ShlinkedinWeb.MenuLive.Index do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, socket |> assign(admin: Shlinkedin.Profiles.is_admin?(socket.assigns.profile))}
  end

  @impl true
  def handle_event("select-page", %{"key" => key}, socket) do
    case key do
      "e" ->
        {:noreply, push_redirect(socket, to: "/users/settings")}

      "a" ->
        {:noreply, push_redirect(socket, to: "/admin")}

      _ ->
        {:noreply, socket}
    end
  end
end
