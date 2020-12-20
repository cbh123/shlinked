defmodule ShlinkedinWeb.ModalComponent do
  use ShlinkedinWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="phx-modal z-50"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="phx-modal-content bg-white max-w-xl m-5 mx-2 mt-8 sm:mx-auto rounded-lg">
        <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close pr-3" %>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
