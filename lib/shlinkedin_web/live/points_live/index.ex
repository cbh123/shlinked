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
       balance: Points.get_balance(socket.assigns.profile),
       transactions: Points.list_transactions(socket.assigns.profile)
     )}
  end

  defp get_profile(id) do
    Shlinkedin.Profiles.get_profile_by_profile_id(id)
  end
end
