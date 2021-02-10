defmodule ShlinkedinWeb.PointsLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Points
  require Integer

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(
       show_profile: socket.assigns.profile,
       balance: Points.get_balance(socket.assigns.profile),
       transactions: Points.list_transactions(socket.assigns.profile),
       wealth_ranking: Shlinkedin.Profiles.get_ranking(socket.assigns.profile, 50, "Wealth")
     )}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _url, socket) do
    show_profile = Shlinkedin.Profiles.get_profile_by_slug(slug)

    {:noreply,
     socket
     |> assign(
       show_profile: show_profile,
       balance: Points.get_balance(show_profile),
       transactions: Points.list_transactions(show_profile),
       wealth_ranking: Shlinkedin.Profiles.get_ranking(show_profile, 50, "Wealth")
     )}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  defp get_profile(id) do
    Shlinkedin.Profiles.get_profile_by_profile_id(id)
  end
end
