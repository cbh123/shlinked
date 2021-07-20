defmodule ShlinkedinWeb.AdLive.SuccessComponent do
  use ShlinkedinWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("success-off", _, socket) do
    {:noreply, socket |> assign(success: false)}
  end
end
