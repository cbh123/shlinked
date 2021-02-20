defmodule ShlinkedinWeb.AdLive.AdComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Ads

  def mount(socket) do
    {:ok, socket |> assign(spin: false)}
  end

  def handle_event("ad-click", %{"id" => id}, socket) do
    ad = Shlinkedin.Ads.get_ad_preload_profile!(id)

    Shlinkedin.Ads.create_ad_click(ad, socket.assigns.profile)

    {:noreply,
     socket |> push_redirect(to: Routes.profile_show_path(socket, :show, ad.profile.slug))}
  end

  def handle_event(
        "like-selected",
        %{"like-type" => like_type},
        %{assigns: %{profile: profile, ad: ad}} = socket
      ) do
    IO.inspect(Ads.is_first_like_on_ad?(profile, ad), label: "is first like")

    if Ads.is_first_like_on_ad?(profile, ad) do
      Ads.create_like(socket.assigns.profile, socket.assigns.ad, like_type)

      send_update(ShlinkedinWeb.AdLive.AdComponent,
        id: socket.assigns.id,
        spin: like_type
      )

      send_update_after(
        ShlinkedinWeb.AdLive.AdComponent,
        [id: socket.assigns.id, spin: nil],
        1000
      )
    else
      Ads.delete_like(profile, ad)
    end

    {:noreply, socket}
  end
end
