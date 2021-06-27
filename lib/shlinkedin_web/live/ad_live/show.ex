defmodule ShlinkedinWeb.AdLive.Show do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    ad = Shlinkedin.Ads.get_ad_preload_profile!(id)

    {:noreply,
     socket
     |> assign(:page_title, "See #{ad.profile.persona_name}'s ad for #{ad.company}")
     |> assign(:ad, ad)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class=" max-w-lg mx-auto mt-8 text-center">

    <%= live_redirect raw("&larr; ShlinkMarket"), to: Routes.market_index_path(@socket, :index),
    class: " inline-flex mx-auto hover:bg-gray-200  px-6 py-3 border border-transparent text-base font-medium rounded-md text-gray-900 "
    %>

    </div>

    <div class="mt-8 relative bg-white shadow-lg sm:max-w-lg mx-auto sm:rounded-lg p-4 mb-2 pb-2">

    <%= live_component @socket, ShlinkedinWeb.AdLive.NewAdComponent,
    ad: @ad,
    id: "ad-#{@ad.id}",
    profile: @profile
    %>

    </div>
    """
  end
end
