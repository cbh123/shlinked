defmodule ShlinkedinWeb.AdLive.AdComponent do
  use ShlinkedinWeb, :live_component

  def handle_event("ad-click", %{"id" => id}, socket) do
    ad = Shlinkedin.Ads.get_ad_preload_profile!(id)
    Shlinkedin.Ads.create_ad_click(ad, socket.assigns.profile)

    {:noreply,
     socket |> push_redirect(to: Routes.profile_show_path(socket, :show, ad.profile.slug))}
  end
end
