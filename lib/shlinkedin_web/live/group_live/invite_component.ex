defmodule ShlinkedinWeb.GroupLive.InviteComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Groups

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       query: nil,
       result: nil,
       loading: false,
       matches: []
     )}
  end

  @impl true
  def update(%{invite: invite} = assigns, socket) do
    changeset = Groups.change_invite(invite)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(matches: Shlinkedin.Profiles.list_random_friends(assigns.profile, 7))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("suggest", %{"q" => q}, socket) do
    matches = Shlinkedin.Profiles.search_profiles(q)
    {:noreply, assign(socket, matches: matches)}
  end
end
