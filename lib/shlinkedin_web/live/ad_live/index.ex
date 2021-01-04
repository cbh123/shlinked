defmodule ShlinkedinWeb.AdLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :ads, list_ads())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ad")
    |> assign(:ad, Ads.get_ad!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ad")
    |> assign(:ad, %Ad{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Ads")
    |> assign(:ad, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ad = Ads.get_ad!(id)
    {:ok, _} = Ads.delete_ad(ad)

    {:noreply, assign(socket, :ads, list_ads())}
  end

  defp list_ads do
    Ads.list_ads()
  end
end
