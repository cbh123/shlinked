defmodule ShlinkedinWeb.TaglineLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline

  @impl true
  def update(%{tagline: tagline} = assigns, socket) do
    changeset = Timeline.change_tagline(tagline)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"tagline" => tagline_params}, socket) do
    changeset =
      socket.assigns.tagline
      |> Timeline.change_tagline(tagline_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"tagline" => tagline_params}, socket) do
    save_tagline(socket, socket.assigns.action, tagline_params)
  end

  defp save_tagline(socket, :edit, tagline_params) do
    case Timeline.update_tagline(socket.assigns.tagline, tagline_params) do
      {:ok, _tagline} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tagline updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_tagline(socket, :new, tagline_params) do
    case Timeline.create_tagline(tagline_params) do
      {:ok, _tagline} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tagline created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
