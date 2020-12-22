defmodule ShlinkedinWeb.StoryLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline

  def mount(_params, session, socket) do
    # get the profile's story where date is within 24 hours, and in order of date
    # get the latest id of that profiles story
    # log this current profile's view
    # if you made the story (or you are an admin), show views
    # if you made the story, button to delete story (maybe edit)
    # for everyone: button to go forward, button to go back, button to share, button to close

    socket = is_user(session, socket)

    # if connected?(socket), do: Process.send_after(self(), :next_story, 5000)

    {:ok, socket}
  end

  def handle_info(:next_story, socket) do
    next_id = Timeline.get_next_story(socket.assigns.show_profile_id, socket.assigns.story.id)

    socket =
      push_patch(socket,
        to: Routes.story_show_path(socket, :show, socket.assigns.profile.id, next_id)
      )

    # Process.send_after(self(), :next_story, 5000)
    {:noreply, socket}
  end

  def handle_event("next-story", _values, socket) do
    next_id = Timeline.get_next_story(socket.assigns.show_profile_id, socket.assigns.story.id)

    {:noreply, socket |> handle_story(next_id)}
  end

  def handle_event("prev-story", _values, socket) do
    prev_id = Timeline.get_prev_story(socket.assigns.show_profile_id, socket.assigns.story.id)

    {:noreply, socket |> handle_story(prev_id)}
  end

  def handle_event("exit-story", _values, socket) do
    {:noreply, socket |> push_redirect(to: Routes.post_index_path(socket, :index))}
  end

  defp handle_story(socket, id) do
    case id do
      nil ->
        socket |> push_redirect(to: Routes.post_index_path(socket, :index))

      number ->
        socket
        |> push_patch(
          to: Routes.story_show_path(socket, :show, socket.assigns.profile.id, number)
        )
    end
  end

  def handle_params(%{"story_id" => story_id}, _url, socket) do
    story = Timeline.get_story!(story_id)

    list = Timeline.get_story_ids(story.profile_id)
    filter = Enum.filter(list, &(&1 <= story_id |> String.to_integer()))

    {:noreply,
     socket
     |> assign(
       story: story,
       show_profile_id: story.profile_id,
       total: list |> length,
       curr: filter |> length
     )}
  end

  def handle_params(%{"profile_id" => profile_id}, _url, socket) do
    story = Timeline.get_profile_story(profile_id)

    socket =
      push_patch(socket,
        to: Routes.story_show_path(socket, :show, profile_id, story.id)
      )

    {:noreply, socket}
  end
end
