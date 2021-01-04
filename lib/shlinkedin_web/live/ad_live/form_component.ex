defmodule ShlinkedinWeb.AdLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Ads

  @impl true
  def update(%{ad: ad} = assigns, socket) do
    changeset = Ads.change_ad(ad)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"ad" => ad_params}, socket) do
    changeset =
      socket.assigns.ad
      |> Ads.change_ad(ad_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"ad" => ad_params}, socket) do
    save_ad(socket, socket.assigns.action, ad_params)
  end

  defp save_ad(socket, :edit, ad_params) do
    case Ads.update_ad(socket.assigns.ad, ad_params) do
      {:ok, _ad} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ad updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_ad(socket, :new, ad_params) do
    case Ads.create_ad(ad_params) do
      {:ok, _ad} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ad created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
