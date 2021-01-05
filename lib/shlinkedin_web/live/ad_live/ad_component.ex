defmodule ShlinkedinWeb.AdLive.AdComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Ads

  def render(assigns) do
    ~L"""

    <%= @ad.body %>
    <%= @ad.slug %>


    """
  end
end
