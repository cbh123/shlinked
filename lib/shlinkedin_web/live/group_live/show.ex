defmodule ShlinkedinWeb.GroupLive.Show do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Groups

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    group = Groups.get_group!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:group, group)
     |> assign(member_status: is_member?(socket.assigns.profile, group))}
  end

  defp page_title(:show), do: "Show Group"
  defp page_title(:edit), do: "Edit Group"

  def handle_event("join-group", %{"id" => id}, socket) do
    group = Groups.get_group!(id)
    Groups.join_group(socket.assigns.profile, group, %{ranking: "member"})

    {:noreply, socket |> assign(member_status: is_member?(socket.assigns.profile, group))}
  end

  @impl true
  def handle_event("leave-group", _, socket) do
    Groups.leave_group(socket.assigns.profile, socket.assigns.group)

    {:noreply,
     socket
     |> put_flash(:info, "You left the group")
     |> push_redirect(to: Routes.group_index_path(socket, :index))}
  end

  defp is_member?(profile, group) do
    Shlinkedin.Groups.is_member?(profile, group)
  end
end
