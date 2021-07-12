defmodule ShlinkedinWeb.TaglineLive.Show do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:tagline, Timeline.get_tagline!(id))}
  end

  defp page_title(:show), do: "Show Tagline"
  defp page_title(:edit), do: "Edit Tagline"
end
