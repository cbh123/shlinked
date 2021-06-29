defmodule ShlinkedinWeb.AdLive.NewAdComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Ads

  def mount(socket) do
    {:ok, socket |> assign(spin: false)}
  end

  def handle_event("censor-ad", _, socket) do
    {:ok, _} = Ads.update_ad(socket.assigns.profile, socket.assigns.ad, %{removed: true})

    {:noreply,
     socket
     |> put_flash(:info, "Ad deleted")
     |> push_redirect(to: Routes.home_index_path(socket, :index))}
  end

  def handle_event("buy-ad", _, %{assigns: %{profile: profile, ad: ad}} = socket) do
    # check ad quantity > 0
    # check that you don't already own
    # check that you have enough money, and then transact money to creator
    # set owner id to current profile
    # notify creator that owner bought
    # send update to component that you own, so buy button goes

    #   if Ads.is_first_like_on_ad?(profile, ad) do
    #     Ads.create_like(socket.assigns.profile, socket.assigns.ad, like_type)

    #     send_update(ShlinkedinWeb.AdLive.AdComponent,
    #       id: socket.assigns.id,
    #       spin: like_type
    #     )

    #     send_update_after(
    #       ShlinkedinWeb.AdLive.AdComponent,
    #       [id: socket.assigns.id, spin: nil],
    #       1000
    #     )

    #     {:noreply, socket |> assign(ad: Ads.get_ad_preload_profile!(ad.id))}
    #   else
    #     Ads.delete_like(profile, ad)
    #     {:noreply, socket |> assign(ad: Ads.get_ad_preload_profile!(ad.id))}
    #   end
  end
end
