defmodule ShlinkedinWeb.ArticleLive.NewsBox do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.ArticleLive.NewsBox

  def handle_event("clap", _params, socket) do
    Shlinkedin.News.create_vote(socket.assigns.profile, socket.assigns.article)

    send_update(NewsBox,
      id: socket.assigns.article.id,
      spin: true
    )

    send_update_after(
      NewsBox,
      [id: socket.assigns.article.id, spin: false],
      1000
    )

    {:noreply, socket}
  end
end
