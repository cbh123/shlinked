defmodule ShlinkedinWeb.SocialPromptLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline

  @impl true
  def update(%{social_prompt: social_prompt} = assigns, socket) do
    changeset = Timeline.change_social_prompt(social_prompt)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"social_prompt" => social_prompt_params}, socket) do
    changeset =
      socket.assigns.social_prompt
      |> Timeline.change_social_prompt(social_prompt_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"social_prompt" => social_prompt_params}, socket) do
    save_social_prompt(socket, socket.assigns.action, social_prompt_params)
  end

  defp save_social_prompt(socket, :edit, social_prompt_params) do
    case Timeline.update_social_prompt(socket.assigns.social_prompt, social_prompt_params) do
      {:ok, _social_prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Social prompt updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_social_prompt(socket, :new, social_prompt_params) do
    case Timeline.create_social_prompt(social_prompt_params) do
      {:ok, _social_prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Social prompt created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
