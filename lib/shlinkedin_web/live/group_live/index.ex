defmodule ShlinkedinWeb.GroupLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Groups
  alias Shlinkedin.Groups.Group

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, assign(socket, groups: list_groups(), profile: socket.assigns.profile)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Create a Group")
    |> assign(:group, %Group{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Groups")
    |> assign(:group, nil)
  end

  defp list_groups do
    Groups.list_groups()
  end
end
