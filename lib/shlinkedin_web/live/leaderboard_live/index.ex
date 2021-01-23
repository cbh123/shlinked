defmodule ShlinkedinWeb.LeaderboardLive.Index do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(
       cat: "shlink_count",
       rankings: Shlinkedin.Profiles.list_profiles_by_unique_post_reactions(25)
     )}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  # def handle_event("show", %{"cat" => cat}, socket) do
  #   socket = assign(socket, key: value)
  #   {:noreply, socket}
  # end
end
