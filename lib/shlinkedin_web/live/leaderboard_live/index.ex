defmodule ShlinkedinWeb.LeaderboardLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles

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

  def handle_params(%{"cat" => cat}, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp match_cat(cat, count) do
    case cat do
      "shlinks" -> Profiles.list_profiles_by_shlink_count(count)
      "post_engagments" -> Profiles.list_profiles_by_unique_post_reactions(count)
    end
  end

  Jabs

  Claps
  Ads
  Reviews

  # def handle_event("show", %{"cat" => cat}, socket) do
  #   socket = assign(socket, key: value)
  #   {:noreply, socket}
  # end
end
