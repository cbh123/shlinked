defmodule ShlinkedinWeb.PostLive.PostLikes do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Timeline.Post

  def render(assigns) do
    ~L"""
    <button id="post-likes-<%=@id%>" phx-click="show-likes" phx-target="<%= @myself %>" phx-value-id="<%= @post.id %>"
    class="<%= if @spin == true, do: "animate-spin" %> inline-flex items-center hover:text-blue-500 hover:underline hover:cursor-pointer py-2 my-2">
    <%= for unique_like <- show_unique_likes(@post) do %>
    <%= if @like_map[unique_like] != nil do %>


    <%= @like_map[unique_like].emoji %>

    <% end %>
    <% end %>

    <p class="text-xs">
        <%= length(@post.likes)%> • <%= (length_unique_user_likes(@post)) %>
    </p>
    </button>
    """
  end

  def handle_event("show-likes", %{"id" => id}, %{assigns: %{return_to: return_to}} = socket) do
    case return_to do
      "/" -> {:noreply, push_patch(socket, to: "/home/posts/#{id}/likes")}
      other -> {:noreply, push_patch(socket, to: other <> "/posts/#{id}/likes")}
    end
  end

  defp show_unique_likes(%Post{} = post) do
    Enum.map(post.likes, fn x -> x.like_type end) |> Enum.uniq()
  end

  defp length_unique_user_likes(%Post{} = post) do
    uniq = Enum.map(post.likes, fn x -> x.profile_id end) |> Enum.uniq() |> length

    case uniq do
      1 -> "1 person"
      uniq -> "#{uniq} people"
    end
  end
end
