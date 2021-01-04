defmodule ShlinkedinWeb.AwardTypeLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Awards

  @impl true
  def update(%{award_type: award_type} = assigns, socket) do
    changeset = Awards.change_award_type(award_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"award_type" => award_type_params}, socket) do
    changeset =
      socket.assigns.award_type
      |> Awards.change_award_type(award_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"award_type" => award_type_params}, socket) do
    save_award_type(socket, socket.assigns.action, award_type_params)
  end

  defp save_award_type(socket, :edit, award_type_params) do
    case Awards.update_award_type(socket.assigns.award_type, award_type_params) do
      {:ok, _award_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Award type updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_award_type(socket, :new, award_type_params) do
    case Awards.create_award_type(award_type_params) do
      {:ok, _award_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Award type created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
