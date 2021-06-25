defmodule ShlinkedinWeb.MarketLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Ads

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, socket |> assign(ads: Ads.get_random_ads(10))}
  end
end
