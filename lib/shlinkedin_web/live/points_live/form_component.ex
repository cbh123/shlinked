defmodule ShlinkedinWeb.PointsLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Points

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset = Points.change_transaction(transaction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Points.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :new_transaction, transaction_params) do
    case Points.create_transaction(
           socket.assigns.from_profile,
           socket.assigns.to_profile,
           transaction_params
         ) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Successfully sent #{transaction_params["amount"]} to #{socket.assigns.to_profile.persona_name}"
         )
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
