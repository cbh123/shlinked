defmodule ShlinkedinWeb.ProfileLive.InternPenComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles

  def update(assigns, socket) do
    socket = socket |> assign(assigns)

    alive_interns = Profiles.list_interns(assigns.show_profile)
    {:ok, socket |> assign(interns: alive_interns, showing_alive: true)}
  end

  def handle_event("graveyard", _, socket) do
    socket =
      assign(socket,
        interns: Profiles.list_interns(socket.assigns.show_profile, "DEVOURED"),
        showing_alive: false
      )

    {:noreply, socket}
  end

  def handle_event("alive", _, socket) do
    socket =
      assign(socket,
        interns: Profiles.list_interns(socket.assigns.show_profile),
        showing_alive: true
      )

    {:noreply, socket}
  end
end
