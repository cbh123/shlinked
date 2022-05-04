defmodule ShlinkedinWeb.HomeLive.WorkComponent do
  use ShlinkedinWeb, :live_component

  def update(assigns, socket) do
    {:ok, assign(socket, has_worked: false, reward_message: nil)}
  end

  def handle_event("work", _, socket) do
    socket =
      assign(socket,
        has_worked: true,
        reward_message: "You work with such grace. How do you do it?"
      )

    {:noreply, socket}
  end
end
