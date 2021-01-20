defmodule ShlinkedinWeb.ProfileLive.InviteForm do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Invite

  @impl true
  def update(%{invite: invite} = assigns, socket) do
    changeset = Profiles.change_invite(invite)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"invite" => params}, socket) do
    changeset =
      socket.assigns.invite
      |> Profiles.change_invite(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"invite" => invite_params}, socket) do
    save_invite(socket, socket.assigns.action, invite_params)
  end

  defp save_invite(%{assigns: %{profile: profile}} = socket, :new_invite, invite_params) do
    case Profiles.create_invite(
           %Invite{profile_id: profile.id},
           invite_params
         ) do
      {:ok, _invite} ->
        {:noreply,
         socket
         |> put_flash(:info, "invite sent")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
