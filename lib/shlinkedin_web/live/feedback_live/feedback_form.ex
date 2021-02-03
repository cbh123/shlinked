defmodule ShlinkedinWeb.FeedbackLive.FeedbackForm do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Feedback.Feedback

  @impl true
  def update(%{feedback: feedback} = assigns, socket) do
    changeset = Shlinkedin.Feedback.change_feedback(feedback)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"feedback" => params}, socket) do
    changeset =
      socket.assigns.feedback
      |> Shlinkedin.Feedback.change_feedback(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"feedback" => feedback_params}, socket) do
    save_feedback(socket, :new_feedback, feedback_params)
  end

  defp save_feedback(socket, :new_feedback, feedback_params) do
    user = Shlinkedin.Accounts.get_user!(socket.assigns.profile.user_id)

    case Shlinkedin.Feedback.create_feedback(
           %Feedback{from_email: user.email},
           feedback_params
         ) do
      {:ok, _feedback} ->
        {:noreply,
         socket
         |> put_flash(:info, "Feedback sent!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
