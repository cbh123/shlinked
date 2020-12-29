defmodule ShlinkedinWeb.SearchLive.SearchBox do
  use ShlinkedinWeb, :live_view

  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, assign(socket, query: nil, loading: false, matches: [], show_search: false)}
  end

  def handle_event("pick", %{"slug" => slug}, socket) do
    IO.inspect(slug, label: "slug")

    {:noreply,
     socket
     |> assign(query: nil, matches: [])
     |> push_redirect(to: Routes.profile_show_path(socket, :show, slug))}
  end

  def handle_event("suggest", %{"q" => q}, socket) do
    if q == "" do
      {:noreply, assign(socket, matches: [])}
    else
      {:noreply, assign(socket, matches: Shlinkedin.Profiles.search_profiles(q))}
    end
  end

  def handle_event("show-search", _params, socket) do
    {:noreply, assign(socket, show_search: true)}
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
