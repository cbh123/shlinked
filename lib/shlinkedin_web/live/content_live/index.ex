defmodule ShlinkedinWeb.ContentLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.News
  alias Shlinkedin.News.Content
  alias Shlinkedin.Profiles

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, assign(socket, :content_collection, list_content())}
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
    |> assign(:page_title, "Shlinkedin News")
    |> assign(:content, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket = check_access(socket, Routes.content_index_path(socket, :index))

    content = News.get_content!(id)
    News.delete_content(socket.assigns.profile, content)

    {:noreply, assign(socket, :content_collection, list_content())}
  end

  defp list_content do
    News.list_content()
  end
end
