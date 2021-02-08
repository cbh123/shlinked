defmodule ShlinkedinWeb.PointsLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Points

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
end
