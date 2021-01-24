defmodule ShlinkedinWeb.LeaderboardLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

  @categories %{
    Shlinks: %{
      title: "count",
      desc: "Total number of shlinked connections."
    },
    "Post Reactions": %{
      title: "reactions",
      desc:
        "The most prestigous ranking - the number of unique post reactions. The number of reactions don't matter (100 YoYs counts just as much as 1) and, reactions on your own post aren't included."
    },
    Claps: %{
      title: "claps",
      desc: "Unique headline claps."
    },
    Reviews: %{
      title: "reviews",
      desc: "Average review rating."
    },
    Ads: %{
      title: "unique clicks",
      desc: "Unique clicks on your ad. You can only get max 1 click from each person per ad."
    }
  }

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    count = 25

    {:ok,
     socket
     |> assign(
       curr_category: :"Post Reactions",
       count: count,
       categories: @categories,
       rankings: Shlinkedin.Profiles.list_profiles_by_unique_post_reactions(count)
     )}
  end

  def handle_params(%{"curr_category" => curr_category}, _url, socket) do
    rankings = match_cat(curr_category, socket.assigns.count)

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

  defp match_cat(category, count) do
    case category do
      "Shlinks" -> Profiles.list_profiles_by_shlink_count(count)
      "Post Reactions" -> Profiles.list_profiles_by_unique_post_reactions(count)
      "Claps" -> Profiles.list_profiles_by_article_votes(count)
      "Reviews" -> Profiles.list_profiles_by_reviews(count)
      "Ads" -> Profiles.list_profiles_by_ad_clicks(count)
    end
  end
end
