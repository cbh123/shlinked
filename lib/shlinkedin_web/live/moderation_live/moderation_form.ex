defmodule ShlinkedinWeb.ModerationLive.ModerationForm do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Moderation

  @impl true
  def update(%{action: action} = assigns, socket) do
    changeset = Moderation.change_action(action)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"action" => action_params}, socket) do
    changeset =
      socket.assigns.action
      |> Moderation.change_action(action_params)
      |> Map.put(:live_action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"action" => action_params}, socket) do
    save_action(socket, socket.assigns.live_action, action_params)
  end

  defp save_action(socket, :edit_action, action_params) do
    case Moderation.update_action(socket.assigns.action, action_params) do
      {:ok, _action} ->
        {:noreply,
         socket
         |> put_flash(:info, "Updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_action(socket, :new_action, action_params) do
    case Moderation.create_action(socket.assigns.content, socket.assigns.profile, action_params) do
      {:ok, _action} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thanks for making ShlinkedIn better :)")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
