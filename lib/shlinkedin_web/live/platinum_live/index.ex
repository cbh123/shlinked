defmodule ShlinkedinWeb.PlatinumLive.Index do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       meta_attrs: [
         %{
           property: "og:image",
           content: "https://shlinked.s3.amazonaws.com/platinum_social.png"
         },
         %{
           name: "twitter:image:src",
           content: "https://shlinked.s3.amazonaws.com/platinum_social.png"
         },
         %{
           property: "og:image:height",
           content: "630"
         },
         %{
           property: "og:image:width",
           content: "1200"
         }
       ]
     )}
  end
end
