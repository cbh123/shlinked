defmodule ShlinkedinWeb.AwardTypeLive.Show do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Awards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:award_type, Awards.get_award_type!(id))}
  end

  defp page_title(:show), do: "Show Award type"
  defp page_title(:edit), do: "Edit Award type"
end
