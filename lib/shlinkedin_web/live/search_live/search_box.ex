defmodule ShlinkedinWeb.SearchLive.SearchBox do
  use ShlinkedinWeb, :live_view

  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, assign(socket, query: nil, loading: false, matches: [], search_focus: false)}
  end

  def handle_event("suggest", %{"q" => q}, socket) do
    if q == "" do
      {:noreply, assign(socket, matches: [])}
    else
      {:noreply, assign(socket, matches: Shlinkedin.Profiles.search_profiles(q))}
    end
  end

  def handle_event("pick", %{"slug" => slug}, socket) do
    socket = redirect(socket, to: Routes.profile_show_path(socket, :show, slug))
    {:noreply, socket}
  end

  def handle_event("all-profiles", _params, socket) do
    socket = redirect(socket, to: Routes.users_index_path(socket, :index))
    {:noreply, socket}
  end

  def handle_event("hide-search", _params, socket) do
    {:noreply, assign(socket, show_search: false)}
  end

  def handle_event("show-search", _params, socket) do
    {:noreply, assign(socket, show_search: true)}
  end
end
