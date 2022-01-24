defmodule ShlinkedinWeb.ContentLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.News
  alias Shlinkedin.News.Content
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(content_collection: list_content())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> check_access(Routes.content_index_path(socket, :index))
    |> assign(:page_title, "Edit Content")
    |> assign(:content, News.get_content!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> check_access(Routes.content_index_path(socket, :index))
    |> assign(:page_title, "New Content")
    |> assign(:content, %Content{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ShlinkedIn Tribune")
    |> assign(:content, nil)
  end

  defp list_content do
    News.list_content()
  end

  def is_allowed?(profile) do
    Shlinkedin.Profiles.is_admin?(profile)
  end
end
