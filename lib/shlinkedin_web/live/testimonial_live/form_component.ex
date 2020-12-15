defmodule ShlinkedinWeb.TestimonialLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Profiles

  @impl true
  def update(%{testimonial: testimonial} = assigns, socket) do
    changeset = Profiles.change_testimonial(testimonial)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"testimonial" => testimonial_params}, socket) do
    changeset =
      socket.assigns.testimonial
      |> Profiles.change_testimonial(testimonial_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"testimonial" => testimonial_params}, socket) do
    save_testimonial(socket, socket.assigns.action, testimonial_params)
  end

  defp save_testimonial(socket, :edit_testimonial, testimonial_params) do
    case Profiles.update_testimonial(socket.assigns.testimonial, testimonial_params) do
      {:ok, _testimonial} ->
        {:noreply,
         socket
         |> put_flash(:info, "Testimonial updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_testimonial(socket, :new_testimonial, testimonial_params) do
    case Profiles.create_testimonial(
           socket.assigns.from_profile,
           socket.assigns.to_profile,
           testimonial_params
         ) do
      {:ok, _testimonial} ->
        {:noreply,
         socket
         |> put_flash(:info, "Testimony created!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
