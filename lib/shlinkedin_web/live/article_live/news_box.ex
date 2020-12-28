defmodule ShlinkedinWeb.ArticleLive.NewsBox do
  use ShlinkedinWeb, :live_component

  def handle_event("clap", _params, socket) do
    Shlinkedin.News.create_vote(socket.assigns.profile, socket.assigns.article)

    {:noreply, socket}
  end
end
