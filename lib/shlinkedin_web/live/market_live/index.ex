defmodule ShlinkedinWeb.MarketLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Ads
  alias Shlinkedin.Points

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    ads = Ads.get_random_ads(8)

    {:ok, socket |> assign(ads: ads, categories: Points.categories(), curr_category: "Ads")}
  end

  def handle_params(%{"curr_category" => curr_category}, _url, socket) do
    {:noreply,
     socket
     |> assign(curr_category: curr_category)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
