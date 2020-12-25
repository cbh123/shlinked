defmodule ShlinkedinWeb.ArticleLive.NewsBox do
  use ShlinkedinWeb, :live_component

  def handle_event("clap", _params, socket) do
    IO.puts("clapped")
    Shlinkedin.News.create_vote(socket.assigns.profile, socket.assigns.article)

    # send_update(NewsBox,
    #   id: socket.assigns.article.id,
    #   spin: true
    # )

    # send_update_after(
    #   PostComponent,
    #   [id: socket.assigns.post.id, spin: false],
    #   1000
    # )

    {:noreply, socket}
  end
end
