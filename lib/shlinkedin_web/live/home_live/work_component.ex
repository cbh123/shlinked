defmodule ShlinkedinWeb.HomeLive.WorkComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles

  def update(assigns, socket) do
    socket = socket |> assign(assigns)
    work_streak = Profiles.get_work_streak(socket.assigns.profile)
    {:ok, assign(socket, has_worked: false, reward_message: nil, work_streak: work_streak)}
  end

  def handle_event("work", _, socket) do
    reward_message = Shlinkedin.Timeline.get_random_reward_message()
    {:ok, _profile} = Profiles.create_work(socket.assigns.profile)
    work_streak = Profiles.get_work_streak(socket.assigns.profile)
    {:ok, profile} = Profiles.update_profile(socket.assigns.profile, %{work_streak: work_streak})

    {:noreply,
     assign(socket,
       has_worked: true,
       reward_message: reward_message.text,
       work_streak: work_streak
     )}
  end
end
