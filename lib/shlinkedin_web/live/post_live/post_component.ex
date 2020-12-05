defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline.Post

  @like_map %{
    "Like" => %{
      like_type: "Like",
      bg: "bg-blue-600",
      bg_hover: "bg-blue-700",
      svg_path:
        "M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z"
    },
    "Pity Like" => %{
      like_type: "Pity Like",
      bg: "bg-indigo-600",
      bg_hover: "bg-indigo-700",
      svg_path:
        "M10 18a8 8 0 100-16 8 8 0 000 16zM7 9a1 1 0 100-2 1 1 0 000 2zm7-1a1 1 0 11-2 0 1 1 0 012 0zm-7.536 5.879a1 1 0 001.415 0 3 3 0 014.242 0 1 1 0 001.415-1.415 5 5 0 00-7.072 0 1 1 0 000 1.415z"
    },
    "Inspired" => %{
      like_type: "Inspired",
      bg: "bg-yellow-500",
      bg_hover: "bg-yellow-600",
      svg_path:
        "M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z"
    },
    "Um..." => %{
      like_type: "Um...",
      bg: "bg-green-500",
      bg_hover: "bg-green-600",
      svg_path:
        "M10 18a8 8 0 100-16 8 8 0 000 16zM4.332 8.027a6.012 6.012 0 011.912-2.706C6.512 5.73 6.974 6 7.5 6A1.5 1.5 0 019 7.5V8a2 2 0 004 0 2 2 0 011.523-1.943A5.977 5.977 0 0116 10c0 .34-.028.675-.083 1H15a2 2 0 00-2 2v2.197A5.973 5.973 0 0110 16v-2a2 2 0 00-2-2 2 2 0 01-2-2 2 2 0 00-1.668-1.973z"
    }
  }

  def handle_event("show-like-options", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: true)
    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_like(socket.assigns.profile, socket.assigns.post, like_type)

    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: false, spin: true)

    send_update_after(
      PostComponent,
      [id: socket.assigns.post.id, spin: false, ping: true],
      1000
    )

    send_update_after(
      PostComponent,
      [id: socket.assigns.post.id, ping: false],
      2000
    )

    {:noreply, socket}
  end

  def handle_event("like-cancelled", _params, socket) do
    send_update(PostComponent, id: socket.assigns.post.id, show_like_options: false)
    {:noreply, socket}
  end

  def show_unique_likes(%Post{} = post) do
    Enum.map(post.likes, fn x -> map_like_to_svg(x.like_type) end) |> Enum.uniq()
  end

  def map_like_to_svg(like_type) do
    case like_type do
      "Like" ->
        %{
          color: "text-blue-500",
          svg_path:
            "M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z"
        }

      "Inspired" ->
        %{
          color: "text-yellow-600",
          svg_path:
            "M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z"
        }

      _ ->
        %{
          color: "text-yellow-600",
          svg_path:
            "M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z"
        }
    end
  end

  def get_likes do
    Enum.map(@like_map, fn {_, d} -> d end)
  end
end
