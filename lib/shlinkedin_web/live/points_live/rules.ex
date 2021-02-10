defmodule ShlinkedinWeb.PointsLive.Rules do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Points
  require Integer

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    socket = assign(socket, rules: Points.rules(), profile: socket.assigns.profile)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :new_feedback, _params) do
    socket
    |> assign(:feedback, %Shlinkedin.Feedback.Feedback{category: "propose rule"})
    |> assign(:page_title, "Propose a rule to the Business Gods")
  end
end
