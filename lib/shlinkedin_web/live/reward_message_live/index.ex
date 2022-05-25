defmodule ShlinkedinWeb.RewardMessageLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.RewardMessage

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    {:ok, check_access(socket) |> assign(:reward_messages, list_reward_messages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Reward message")
    |> assign(:reward_message, Timeline.get_reward_message!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Reward message")
    |> assign(:reward_message, %RewardMessage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Reward messages")
    |> assign(:reward_message, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    reward_message = Timeline.get_reward_message!(id)
    {:ok, _} = Timeline.delete_reward_message(reward_message)

    {:noreply, assign(socket, :reward_messages, list_reward_messages())}
  end

  defp list_reward_messages do
    Timeline.list_reward_messages()
  end
end
