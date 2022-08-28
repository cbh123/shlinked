defmodule ShlinkedinWeb.MarketLive.AdsListComponent do
  use ShlinkedinWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex justify-between mb-3">
    <div>
        <div class="inline-flex">

            <.form let={f} for={:category}  phx-change="sort_ads">

            <select id="sort-ads" name="sort-ads"
                class="mt-1 inline-block pl-3 pr-8 py-2 border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-sm rounded-md">
                <option>Sort by Creation Date</option>
                <option>Sort by Price</option>
            </select>

            <div class="mt-2 sm:pl-6 sm:mt-0 flex sm:inline-flex items-center align-middle">
                <!-- Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200" -->
                <button type="button" id="toggle-sold" phx-click="toggle_show_sold"
                    phx-value-show={@sort_options.show_sold}
                    class={if @sort_options.show_sold, do: "bg-blue-600", else: "bg-gray-200"} relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                    role="switch" aria-checked="false" aria-labelledby="show-sold-ads">
                    <!-- Enabled: "translate-x-5", Not Enabled: "translate-x-0" -->
                    <span aria-hidden="true"
                        class={"#{if @sort_options.show_sold, do: "translate-x-5", else: "translate-x-0"} pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"}></span>
                </button>
                <span class="ml-3" id="include-sold">
                    <span class="text-sm font-medium text-gray-900">Include
                        sold ads</span>
                </span>
            </div>

            </.form>


        </div>


    </div>


    <%= live_patch to: Routes.market_index_path(@socket, :new_ad) do %>
    <button type="button"
        class="flex max-w-sm mx-auto items-center px-6 py-3 text-xl font-extrabold rounded-full text-white bg-gradient-to-tr from-indigo-600 to-blue-500 hover:from-indigo-500 hover:to-blue-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        +
        New Ad
    </button>

    <% end %>
    </div>


    <ul role="list" id="ads" phx-update={@update_action} data-page={@page}
    class=" grid grid-cols-1 gap-x-4 gap-y-8 sm:grid-cols-2 sm:gap-x-6 lg:grid-cols-3 xl:gap-x-8">

    <%= for ad <- @ads do %>
    <%= live_component ShlinkedinWeb.AdLive.NewAdComponent, ad: ad,
            id: "ad-#{ad.id}",
            profile: @profile,
            type: :market
        %>
    <% end %>
    </ul>


    <footer id="footer" phx-hook="InfiniteScroll" class="mt-8 text-center text-6xl font-bold">
    <%= if @page >= @total_pages do %>
    <p>That's it.</p>
    <% else %>
    <span class="animate-pulse font-windows">💵
        Loading...</span>
    <% end %>
    </footer>

    """
  end
end
