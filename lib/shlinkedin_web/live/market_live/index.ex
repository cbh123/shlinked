defmodule ShlinkedinWeb.MarketLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Points

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    show_sold = show_sold?(socket.assigns.profile)

    sort_options = %{sort_by: :inserted_at, sort_order: :desc, show_sold: show_sold}
    page = 1
    per_page = 6

    ads = Ads.list_ads(paginate: %{page: page, per_page: per_page}, sort: sort_options)

    {:ok,
     socket
     |> assign(
       ads: ads,
       update_action: "append",
       categories: Points.categories(),
       curr_category: "Ads",
       total_pages: calc_max_pages(show_sold, per_page),
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

  defp apply_action(socket, :edit_ad, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ad")
    |> assign(:ad, Ads.get_ad_preload_profile!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ShlinkMarket")
  end

  def handle_event(
        "toggle_show_sold",
        _params,
        %{assigns: %{profile: profile, sort_options: sort_options}} = socket
      ) do
    show_sold = !sort_options.show_sold
    {:ok, _profile} = Shlinkedin.Profiles.update_profile(profile, %{"show_sold_ads" => show_sold})

    sort_options = Map.replace(sort_options, :show_sold, show_sold)
    total_pages = calc_max_pages(show_sold, socket.assigns.per_page)

    {:noreply,
     socket
     |> assign(
       total_pages: total_pages,
       sort_options: sort_options,
       update_action: "replace",
       page: 1
     )
     |> fetch_ads()}
  end

  @impl true
  def handle_event("sort_ads", %{"sort-ads" => "Sort by Creation Date"}, socket) do
    sort_options = %{sort_by: :inserted_at, sort_order: :desc}

    {:noreply,
     socket
     |> assign(sort_options: sort_options, update_action: "replace", page: 1)
     |> fetch_ads()}
  end

  def handle_event("sort_ads", %{"sort-ads" => "Sort by Price"}, socket) do
    sort_options = %{sort_by: :price, sort_order: :desc}

    {:noreply,
     socket
     |> assign(sort_options: sort_options, update_action: "replace", page: 1)
     |> fetch_ads()}
  end

  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))
      |> assign(update_action: "append")
      |> fetch_ads()

    {:noreply, socket}
  end

  defp fetch_ads(
         %{assigns: %{page: page, per_page: per_page, sort_options: sort_options}} = socket
       ) do
    ads = Ads.list_ads(paginate: %{page: page, per_page: per_page}, sort: sort_options)

    assign(socket,
      ads: ads
    )
  end

  defp calc_max_pages(show_sold, per_page) do
    total_ads = Ads.get_num_ads(show_sold: show_sold)
    trunc(total_ads / per_page)
  end

  defp show_sold?(profile) do
    profile.show_sold_ads
  end
end
