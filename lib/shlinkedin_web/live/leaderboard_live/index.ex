defmodule ShlinkedinWeb.LeaderboardLive.Index do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(
       cat: "shlink_count",
       rankings: Shlinkedin.Profiles.list_profiles_by_shlink_count(25)
     )}
  end

  # def handle_event("show", %{"cat" => cat}, socket) do
  #   socket = assign(socket, key: value)
  #   {:noreply, socket}
  # end
end
