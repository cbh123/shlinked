defmodule ShlinkedinWeb.LeaderboardLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    count = 25
    weekly = true

    {:ok,
     socket
     |> assign(
       curr_category: :"Post Reactions",
       weekly: weekly,
       count: count,
       categories: Profiles.categories(),
       rankings:
         Profiles.list_profiles_by_unique_post_reactions(
           count,
           get_start_date(weekly)
         )
     )}
  end

  def handle_params(%{"curr_category" => curr_category, "weekly" => weekly}, _url, socket) do
    start_date = get_start_date(weekly |> String.to_atom())
    rankings = Profiles.match_cat(curr_category, socket.assigns.count, start_date)

    {:noreply,
     socket
     |> assign(
       rankings: rankings,
       page_title: "#{curr_category} Leaders",
       curr_category: curr_category |> String.to_atom(),
       weekly: weekly |> String.to_atom()
     )}
  end

  def handle_params(%{"curr_category" => curr_category}, _url, socket) do
    start_date = get_start_date(socket.assigns.weekly)
    rankings = Profiles.match_cat(curr_category, socket.assigns.count, start_date)

    {:noreply,
     socket
     |> assign(
       rankings: rankings,
       page_title: "#{curr_category} Leaders",
       curr_category: curr_category |> String.to_atom()
     )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("handle_select", %{"selected-tab" => category}, socket) do
    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.leaderboard_index_path(socket, :index, curr_category: category |> String.to_atom())
     )}
  end

  @impl true
  def handle_event("toggle-weekly", _, socket) do
    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.leaderboard_index_path(socket, :index,
           curr_category: socket.assigns.curr_category,
           weekly: !socket.assigns.weekly
         )
     )}
  end

  # convert UTC now to EST at noon
  @twenty_three_hours 23 * 60 * 60

  defp get_start_date(weekly) do
    if weekly,
      do:
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(-@twenty_three_hours)
        |> Timex.beginning_of_week(:sun),
      else: ~N[2000-01-01 00:00:00]
  end
end
