defmodule ShlinkedinWeb.ProfileLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Accounts
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Endorsement

  def mount(%{"slug" => slug}, session, socket) do
    show_profile = Shlinkedin.Profiles.get_profile_by_slug(slug)

    # KNOWN BUG: RIGHT WHEN YOU CREATE AN ACCOUNT, THIS BUTTON DOESN"T WORK! PROBLABLY NOT LOADED INTO SOCKET!
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(live_action: :show)
     |> assign(show_profile: show_profile)
     |> assign(from_profile: socket.assigns.profile)
     |> assign(to_profile: show_profile)
     |> assign(endorsements: list_endorsements(show_profile.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :edit_endorsement, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Endorsement")
    |> assign(:endorsement, Profiles.get_endorsement!(id))
  end

  defp apply_action(socket, :new_endorsement, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Endorse #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:endorsement, %Endorsement{})
  end

  @impl true
  def handle_event("delete-endorsement", %{"id" => id}, socket) do
    endorsement = Profiles.get_endorsement!(id)
    {:ok, _} = Profiles.delete_endorsement(endorsement)

    {:noreply, assign(socket, :endorsements, list_endorsements(socket.assigns.to_profile.id))}
  end

  defp list_endorsements(id) do
    Profiles.list_endorsements(id)
  end

  def get_profile(id) do
    Profiles.get_profile(id)
  end
end
