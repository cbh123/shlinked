defmodule ShlinkedinWeb.MarketLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Points

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    sort_options = %{sort_by: :inserted_at, sort_order: :desc}
    page = 1
    per_page = 5

    ads = Ads.list_ads(paginate: %{page: page, per_page: per_page}, sort: sort_options)

    {:ok,
     socket
     |> assign(
       ads: ads,
       update_action: "append",
       categories: Points.categories(),
       curr_category: "Ads",
       page: page,
       per_page: per_page,
       sort_options: sort_options
     ), temporary_assigns: [ads: []]}
  end

  @impl true
  def handle_params(%{"curr_category" => curr_category}, _url, socket) do
    {:noreply,
     socket
     |> assign(curr_category: curr_category)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_ad, _params) do
    socket
    |> assign(:page_title, "Create an Ad")
    |> assign(:ad, %Ad{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ShlinkMarket")
  end

  def handle_event("sort_ads", %{"sort-ads" => "Creation Date"}, socket) do
    sort_options = %{sort_by: :inserted_at, sort_order: :desc}

    {:noreply,
     socket
     |> assign(sort_options: sort_options, update_action: "replace", page: 1)
     |> fetch_ads()}
  end

  def handle_event("sort_ads", %{"sort-ads" => "Price"}, socket) do
    sort_options = %{sort_by: :price, sort_order: :desc}

    {:noreply,
     socket
     |> assign(sort_options: sort_options, update_action: "replace", page: 1)
     |> fetch_ads()}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1, update_action: "append") |> fetch_ads()}
  end

  defp fetch_ads(
         %{assigns: %{page: page, per_page: per_page, sort_options: sort_options}} = socket
       ) do
    ads = Ads.list_ads(paginate: %{page: page, per_page: per_page}, sort: sort_options)

    assign(socket,
      ads: ads
    )
  end
end
