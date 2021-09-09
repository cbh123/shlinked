defmodule ShlinkedinWeb.AdLive.NewAdComponent do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.{Chat, Chat.Conversation}
  alias Shlinkedin.Profiles.Profile

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       spin: false,
       error: nil,
       success: false,
       bought_ad: nil
     )}
  end

  def handle_event("view", %{"owner-id" => profile_id}, socket) do
    profile = Shlinkedin.Profiles.get_profile_by_profile_id(profile_id)
    {:noreply, socket |> push_redirect(to: Routes.profile_show_path(socket, :show, profile.slug))}
  end

  def handle_event("message", %{"owner-id" => owner_id}, socket) do
    profile_ids = [socket.assigns.profile.id, owner_id]

    profile_ids
    |> Enum.sort()
    |> Enum.map(&to_string/1)
    |> create_or_find_convo?()
    |> redirect_conversation(socket)
  end

  def handle_event("ad-click", %{"id" => id}, socket) do
    Ads.get_ad!(id)
    |> Ads.create_ad_click(socket.assigns.profile)

    {:noreply, socket |> push_redirect(to: Routes.ad_show_path(socket, :show, id))}
  end

  def handle_event("toggle-success", _, socket) do
    socket = assign(socket, success: !socket.assigns.success)
    {:noreply, socket}
  end

  def handle_event("censor-ad", _, socket) do
    {:ok, _} = Ads.update_ad(socket.assigns.ad, socket.assigns.profile, %{removed: true})

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
          [id: socket.assigns.id, spin: false, ad: ad],
          1000
        )

        send_update_after(
          ShlinkedinWeb.AdLive.NewAdComponent,
          [id: socket.assigns.id, success: true, bought_ad: ad],
          1000
        )

        {:noreply, socket}

      {:error, message} ->
        {:noreply, socket |> assign(error: render_error(message))}
    end
  end

  # because error can come through as text or changeset error
  defp render_error(%Ecto.Changeset{} = changeset) do
    changeset_error_to_string(changeset)
  end

  defp render_error(text), do: text

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

  def changeset_error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {_k, v} ->
      joined_errors = Enum.join(v, "; ")
      "#{joined_errors}\n"
    end)
  end

  defp get_ad_creator(%Ad{profile_id: profile_id}),
    do: Shlinkedin.Profiles.get_profile_by_profile_id(profile_id)

  defp count_unique_ad_clicks(ad), do: Ads.count_unique_ad_clicks_for_ad(ad)

  defp is_owner?(%Ad{} = ad, %Profile{} = profile), do: ad.owner_id == profile.id
  defp is_sold?(%Ad{} = ad), do: not is_nil(ad.owner_id)
end
