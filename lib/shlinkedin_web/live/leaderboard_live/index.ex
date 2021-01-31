defmodule ShlinkedinWeb.LeaderboardLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  @categories %{
    Shlinks: %{
      title: "count",
      desc: "Total number of shlinked connections.",
      emoji: "🤝"
    },
    "Post Reactions": %{
      title: "reactions",
      desc:
        "The most prestigous ranking - the number of unique post reactions. The number of reactions don't matter (100 YoYs counts just as much as 1) and, reactions on your own post aren't included.",
      emoji: "🪧"
    },
    Claps: %{
      title: "claps",
      desc: "Unique headline claps.",
      emoji: "👏"
    },
    Ads: %{
      title: "unique clicks",
      desc: "Unique clicks on your ad. You can only get max 1 click from each person per ad.",
      emoji: "👁️"
    },
    Hottest: %{
      title: "profile views",
      desc: "Unique profile views, from everyone but yourself.",
      emoji: "🔥"
    }
  }

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
       categories: @categories,
       rankings:
         Profiles.list_profiles_by_unique_post_reactions(
           count,
           get_start_date(weekly)
         )
     )}
  end

  def handle_params(%{"curr_category" => curr_category, "weekly" => weekly}, _url, socket) do
    rankings = match_cat(curr_category, socket.assigns.count, weekly |> String.to_atom())

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
    rankings = match_cat(curr_category, socket.assigns.count, socket.assigns.weekly)

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

  defp match_cat(category, count, weekly) do
    start_date = get_start_date(weekly)

    case category do
      "Shlinks" -> Profiles.list_profiles_by_shlink_count(count, start_date)
      "Post Reactions" -> Profiles.list_profiles_by_unique_post_reactions(count, start_date)
      "Claps" -> Profiles.list_profiles_by_article_votes(count, start_date)
      "Ads" -> Profiles.list_profiles_by_ad_clicks(count, start_date)
      "Hottest" -> Profiles.list_profiles_by_profile_views(count, start_date)
    end
  end

  @seventeen_hours 17 * 60 * 60

  defp get_start_date(weekly) do
    if weekly,
      do:
        Timex.beginning_of_week(
          NaiveDateTime.utc_now() |> NaiveDateTime.add(@seventeen_hours),
          :sun
        ),
      else: ~N[2000-01-01 00:00:00]
  end
end
