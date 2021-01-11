defmodule ShlinkedinWeb.GroupLive.GroupComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Groups

  def handle_event("join-group", %{"id" => id}, socket) do
    group = Groups.get_group!(id)
    Groups.join_group(socket.assigns.profile, group, %{ranking: "member"})

    send_update(ShlinkedinWeb.GroupLive.GroupComponent,
      id: group.id,
      member_status: Shlinkedin.Groups.is_member?(socket.assigns.profile, group)
    )

    {:noreply, socket}
  end
end
