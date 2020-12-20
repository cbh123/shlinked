defmodule ShlinkedinWeb.EndorsementLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Profiles

  @impl true
  def update(%{endorsement: endorsement} = assigns, socket) do
    changeset = Profiles.change_endorsement(endorsement)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"endorsement" => endorsement_params}, socket) do
    changeset =
      socket.assigns.endorsement
      |> Profiles.change_endorsement(endorsement_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"endorsement" => endorsement_params}, socket) do
    save_endorsement(socket, socket.assigns.action, endorsement_params)
  end

  defp save_endorsement(socket, :edit_endorsement, endorsement_params) do
    case Profiles.update_endorsement(socket.assigns.endorsement, endorsement_params) do
      {:ok, _endorsement} ->
        {:noreply,
         socket
         |> put_flash(:info, "Endorsement updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_endorsement(socket, :new_endorsement, endorsement_params) do
    case Profiles.create_endorsement(
           socket.assigns.from_profile,
           socket.assigns.to_profile,
           endorsement_params
         ) do
      {:ok, _endorsement} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "You endorsed #{socket.assigns.to_profile.persona_name} for #{
             endorsement_params["body"]
           }"
         )
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
