defmodule ShlinkedinWeb.MessageTemplateLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Chat

  @impl true
  def update(%{message_template: message_template} = assigns, socket) do
    changeset = Chat.change_message_template(message_template)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"message_template" => message_template_params}, socket) do
    changeset =
      socket.assigns.message_template
      |> Chat.change_message_template(message_template_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"message_template" => message_template_params}, socket) do
    save_message_template(socket, socket.assigns.action, message_template_params)
  end

  defp save_message_template(socket, :edit, message_template_params) do
    case Chat.update_message_template(socket.assigns.message_template, message_template_params) do
      {:ok, _message_template} ->
        {:noreply,
         socket
         |> put_flash(:info, "Message template updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_message_template(socket, :new, message_template_params) do
    case Chat.create_message_template(message_template_params) do
      {:ok, _message_template} ->
        {:noreply,
         socket
         |> put_flash(:info, "Message template created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
