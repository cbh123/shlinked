defmodule ShlinkedinWeb.ArticleLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.News
  alias Shlinkedin.News.Article

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      News.subscribe()
    end

    socket = is_user(session, socket)
    {:ok, assign(socket, :articles, list_articles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_article, _params) do
    socket
    |> assign(:page_title, "New Headline")
    |> assign(:article, %Article{})
  end

  defp apply_action(socket, :show_votes, %{"id" => id}) do
    article = News.get_article_preload_votes!(id)

    socket
    |> assign(:page_title, "Claps")
    |> assign(
      :votes,
      News.list_votes(article)
    )
    |> assign(:article, article)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ShlinkNews")
    |> assign(:article, nil)
  end

  @impl true
  def handle_event("delete-article", %{"id" => id}, socket) do
    article = News.get_article!(id)
    {:ok, _} = News.delete_article(article)

    {:noreply, assign(socket, :articles, list_articles())}
  end

  @impl true
  def handle_info({:article_updated, article}, socket) do
    {:noreply, update(socket, :articles, fn articles -> [article | articles] end)}
  end

  defp list_articles do
    News.list_articles()
  end
end
