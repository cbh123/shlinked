defmodule ShlinkedinWeb.AdLive.NewAdComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Ads
  alias Shlinkedin.{Chat, Chat.Conversation}

  def mount(socket) do
    {:ok, socket |> assign(spin: false, error: nil)}
  end

  def handle_event("censor-ad", _, socket) do
    {:ok, _} = Ads.update_ad(socket.assigns.ad, %{removed: true})

    {:noreply,
     socket
     |> put_flash(:info, "Ad deleted")
     |> push_redirect(to: Routes.home_index_path(socket, :index))}
  end

  def handle_event("buy-ad", _, %{assigns: %{profile: profile, ad: ad}} = socket) do
    case Ads.buy_ad(ad, profile) do
      {:ok, ad} ->
        send_update(ShlinkedinWeb.AdLive.NewAdComponent,
          id: socket.assigns.id,
          spin: true
        )

        send_update_after(
          ShlinkedinWeb.AdLive.NewAdComponent,
          [id: socket.assigns.id, spin: false, owner: profile],
          1000
        )

        {:noreply, socket}

      {:error, message} ->
        {:noreply, socket |> assign(error: message)}
    end
  end

  def handle_event("message", %{"owner-id" => owner_id}, socket) do
    profile_ids = [socket.assigns.profile.id, owner_id]

    profile_ids
    |> Enum.sort()
    |> Enum.map(&to_string/1)
    |> create_or_find_convo?()
    |> redirect_conversation(socket)
  end

  defp create_or_find_convo?(profile_ids) when is_list(profile_ids) do
    case Chat.conversation_exists?(profile_ids) do
      %Conversation{} = convo ->
        {:ok, convo}

      nil ->
        %{
          "conversation_members" => conversation_members_format(profile_ids),
          "profile_ids" => profile_ids |> Enum.sort()
        }
        |> Chat.create_conversation()
    end
  end

  defp redirect_conversation({:ok, %Conversation{id: id}}, socket) do
    {:noreply,
     socket
     |> push_redirect(to: Routes.message_show_path(socket, :show, id))}
  end

  defp conversation_members_format(profile_ids) do
    profile_ids
    |> Enum.with_index()
    |> Enum.sort()
    |> Enum.map(fn {id, i} -> {to_string(i), %{"profile_id" => id}} end)
    |> Enum.into(%{})
  end
end
