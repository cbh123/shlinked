defmodule ShlinkedinWeb.TaglineLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Tagline

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    {:ok, socket |> check_access() |> assign(:taglines, list_taglines())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tagline")
    |> assign(:tagline, Timeline.get_tagline!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tagline")
    |> assign(:tagline, %Tagline{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Taglines")
    |> assign(:tagline, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tagline = Timeline.get_tagline!(id)
    {:ok, _} = Timeline.delete_tagline(tagline)

    {:noreply, assign(socket, :taglines, list_taglines())}
  end

  defp list_taglines do
    Timeline.list_taglines()
  end
end
