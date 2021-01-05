defmodule ShlinkedinWeb.AdLive.AdComponent do
  use ShlinkedinWeb, :live_component

  def render(assigns) do
    ~L"""

    <%= @ad.body %>
    <%= @ad.slug %>


    """
  end
end
