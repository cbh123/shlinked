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

  def handle_event("suggest", %{"q" => q}, socket) do
    matches = Shlinkedin.Profiles.search_profiles(q)
    {:noreply, assign(socket, matches: matches)}
  end

  def handle_event("search", %{"q" => q}, socket) when byte_size(q) <= 100 do
    send(self(), {:search, q})
    {:noreply, assign(socket, query: q, result: "…", loading: true, matches: [])}
  end

  def handle_info({:search, query}, socket) do
    {result, _} = System.cmd("dict", ["#{query}"], stderr_to_stdout: true)
    {:noreply, assign(socket, loading: false, result: result, matches: [])}
  end

  @impl true
  def handle_event("validate", %{"invite" => invite_params}, socket) do
    changeset =
      socket.assigns.invite
      |> Groups.change_invite(invite_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"invite" => invite_params}, socket) do
    save_invite(socket, socket.assigns.action, invite_params)
  end

  defp save_invite(%{assigns: %{profile: profile}} = socket, :new_invite, invite_params) do
    IO.inspect(invite_params, label: "")
  end
end
