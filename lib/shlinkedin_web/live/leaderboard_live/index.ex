defmodule ShlinkedinWeb.LeaderboardLive.Index do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, socket}
  end
end
