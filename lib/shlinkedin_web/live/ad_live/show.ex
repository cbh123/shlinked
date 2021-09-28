defmodule ShlinkedinWeb.AdLive.Show do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket = is_user(session, socket)
    ad = Shlinkedin.Ads.get_ad_preload_profile!(id)

    {:ok,
     socket
     |> assign(ad: ad)
     |> assign(
       :page_title,
       "See #{ad.profile.persona_name}'s ad for #{ad.company}"
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :new_action, _params) do
    socket |> assign(action: %Shlinkedin.Moderation.Action{})
  end

  defp apply_action(socket, :edit_action, %{"action_id" => action_id}) do
    action = Shlinkedin.Moderation.get_action!(action_id)
    socket |> assign(action: action)
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class=" max-w-lg mx-auto mt-8 text-center">

    <%= live_redirect raw("&larr; ShlinkMarket"), to: Routes.market_index_path(@socket, :index), class: " inline-flex mx-auto hover:bg-gray-200  px-6 py-3 border border-transparent text-base font-medium rounded-md text-gray-900"%>
    </div>

    <div class="mt-3 mx-auto sm:rounded-lg max-w-lg p-5">
    <ul>
    <%= live_component @socket, ShlinkedinWeb.AdLive.NewAdComponent,
    ad: @ad,
    id: "ad-#{@ad.id}",
    profile: @profile,
    type: :show
    %>
    </ul>

    <%= @ad.removed %>

    <%= if @live_action in [:new_action, :edit_action] do %>
    <%= live_modal @socket, ShlinkedinWeb.ModerationLive.ModerationForm,
                            id: "moderate-#{@ad.id}",
                            profile: @profile,
                            live_action: @live_action,
                            content: @ad,
                            action: @action,
                            return_to: Routes.ad_show_path(@socket, :show, @ad.id)
                        %>
    <% end %>

    </div>
    """
  end
end
