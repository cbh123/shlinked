defmodule ShlinkedinWeb.PostLive.PostLikes do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Timeline.Post

  def render(assigns) do
    ~L"""
    <button id="post-<%=@id%>" phx-click="show-likes" phx-target="<%= @myself %>" phx-value-id="<%= @post.id %>"
    class="<%= if @spin == true, do: "animate-spin" %> text-xs inline-flex items-center hover:text-blue-500 hover:underline hover:cursor-pointer py-2 my-2">
    <%= for unique_like <- show_unique_likes(@post) do %>
    <%= if @like_map[unique_like] != nil do %>

    <%= if @like_map[unique_like].is_emoji do %>
    <%= @like_map[unique_like].emoji %>
    <% else %>
    <svg class="-ml-1 mr-1 h-3 w-3 <%= @like_map[unique_like].color %> hover:underline hover:cursor-pointer"
        fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
        <path fill-rule="<%= @like_map[unique_like].fill %>" d="<%= @like_map[unique_like].svg_path %>">
        </path>
    </svg>
    <% end %>
    <% end %>
    <% end %>


        <%= length(@post.likes)%> • <%= (length_unique_user_likes(@post)) %>

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
