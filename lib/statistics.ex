defmodule Shlinkedin.Statistics do
  use GenServer
  alias Shlinkedin.Points

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    total_points = Points.get_total_points()
    {:ok, _stat} = Points.create_statistic(%{total_points: total_points})

    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # In 2 hours
    Process.send_after(self(), :work, 2 * 60 * 60 * 1000)
  end
end
