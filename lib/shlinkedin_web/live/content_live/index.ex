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
     |> assign(
       headline_update_action: "append",
       headline_page: 1,
       headline_per_page: 15,
       content_collection: list_content(),
       headline_options: get_headline_options(socket.assigns.profile)
     )
     |> fetch_headlines()}
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

  defp list_content do
    News.list_content()
  end

  defp fetch_headlines(
         %{
           assigns: %{
             headline_page: page,
             headline_per_page: per_page,
             headline_options: headline_options
           }
         } = socket
       ) do
    articles = News.list_articles([paginate: %{page: page, per_page: per_page}], headline_options)
    assign(socket, articles: articles)
  end

  def is_allowed?(profile) do
    Shlinkedin.Profiles.is_admin?(profile)
  end

  defp get_headline_options(%Profile{} = profile) do
    %{
      type: profile.headline_type,
      time: profile.headline_time
    }
  end

  defp get_headline_options(nil) do
    %{
      type: "reactions",
      time: "week"
    }
  end

  def handle_event("sort-headlines", %{"type" => type, "time" => time}, socket) do
    {:noreply,
     socket
     |> push_patch(
       to: Routes.content_index_path(socket, :index, headline_type: type, headline_time: time)
     )}
  end

  def handle_event("more-headlines", _, socket) do
    {:noreply,
     socket
     |> assign(headline_update_action: "append", headline_page: socket.assigns.headline_page + 1)
     |> fetch_headlines()}
  end

  @impl true
  def handle_event("delete-article", %{"id" => id}, socket) do
    article = News.get_article!(id)
    {:ok, _} = News.delete_article(article)

    {:noreply,
     socket
     |> put_flash(:info, "Headline deleted")
     |> push_redirect(to: Routes.content_index_path(socket, :index))}
  end
end
