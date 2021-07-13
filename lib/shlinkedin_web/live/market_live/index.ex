defmodule ShlinkedinWeb.MarketLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Ads

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    ads = Ads.get_random_ads(10)

    {:ok, socket |> assign(ads: ads)}
  end
end
