defmodule ShlinkedinWeb.SearchLive.SearchBox do
  use ShlinkedinWeb, :live_view

  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, assign(socket, query: nil, loading: false, matches: [])}
  end

  def handle_event("suggest", %{"q" => q}, socket) do
    {:noreply, assign(socket, matches: Shlinkedin.Profiles.search_profiles(q))}
  end

  def handle_event("search", %{"q" => q}, socket) do
    send(self(), {:search, q})
    {:noreply, assign(socket, query: q, loading: true, matches: [])}
  end

  def handle_info({:search, query}, socket) do
    result = Shlinkedin.Profiles.search_profiles(query)
    {:noreply, assign(socket, loading: false, result: result, matches: [])}
  end
end
