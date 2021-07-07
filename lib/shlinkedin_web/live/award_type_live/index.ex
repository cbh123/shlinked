defmodule ShlinkedinWeb.AwardTypeLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Awards
  alias Shlinkedin.Awards.AwardType

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     check_access(socket)
     |> assign(live_action: socket.assigns.live_action || :index, award_types: list_award_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Award")
    |> assign(:award_type, Awards.get_award_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add a New Award")
    |> assign(:award_type, %AwardType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Awards")
    |> assign(:award_type, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    award_type = Awards.get_award_type!(id)
    {:ok, _} = Awards.delete_award_type(award_type)

    {:noreply, assign(socket, :award_types, list_award_types())}
  end

  defp list_award_types() do
    Awards.list_award_types()
  end
end
