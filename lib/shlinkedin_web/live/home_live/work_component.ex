defmodule ShlinkedinWeb.HomeLive.WorkComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Profiles

  def update(assigns, socket) do
    socket = socket |> assign(assigns)
    work_streak = Profiles.get_work_streak(socket.assigns.profile)
    interns = get_interns(socket.assigns.profile)

    {:ok,
     assign(socket,
       just_worked: false,
       reward_message: nil,
       work_streak: work_streak,
       interns: interns
     )}
  end

  def has_worked_today?(profile), do: Profiles.has_worked_today?(profile)

  def handle_event("work", _, %{assigns: %{profile: nil}} = socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Sorry, you must make a profile to WORK")
     |> push_patch(to: Routes.home_index_path(socket, :index))}
  end

  def handle_event("work", _, %{assigns: %{profile: profile}} = socket) do
    reward_message = Shlinkedin.Timeline.get_random_reward_message()

    if not has_worked_today?(profile) do
      {:ok, _work} = Profiles.create_work(profile)
      work_streak = Profiles.get_work_streak(profile)
      {:ok, _profile} = Profiles.update_profile(profile, %{work_streak: work_streak})

      {:noreply,
       assign(socket,
         just_worked: true,
         has_worked_today: true,
         reward_message: reward_message.text,
         work_streak: work_streak
       )}
    else
      {:noreply,
       socket
       |> put_flash(:info, "Sorry, you must make a profile to WORK")
       |> push_patch(to: Routes.home_index_path(socket, :index))}
    end
  end

  def get_interns(nil), do: 1
  def get_interns(profile), do: profile.interns
end
