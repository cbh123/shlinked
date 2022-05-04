defmodule ShlinkedinWeb.RewardMessageLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline

  @impl true
  def update(%{reward_message: reward_message} = assigns, socket) do
    changeset = Timeline.change_reward_message(reward_message)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"reward_message" => reward_message_params}, socket) do
    changeset =
      socket.assigns.reward_message
      |> Timeline.change_reward_message(reward_message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"reward_message" => reward_message_params}, socket) do
    save_reward_message(socket, socket.assigns.action, reward_message_params)
  end

  defp save_reward_message(socket, :edit, reward_message_params) do
    case Timeline.update_reward_message(socket.assigns.reward_message, reward_message_params) do
      {:ok, _reward_message} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reward message updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_reward_message(socket, :new, reward_message_params) do
    case Timeline.create_reward_message(reward_message_params) do
      {:ok, _reward_message} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reward message created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
