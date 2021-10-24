defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline
  alias Shlinkedin.Profiles.Profile

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(prompt: get_prompt())}
  end

  @impl true
  def handle_event(_action, _params, %{assigns: %{profile: %Profile{id: nil}}} = socket) do
    {:noreply,
     socket
     |> put_flash(:info, "You must join ShlinkedIn to do that :)")
     |> push_patch(to: socket.assigns.return_to)}
  end

  @impl true
  def handle_event(_action, _params, %{assigns: %{profile: nil}} = socket) do
    {:noreply,
     socket
     |> put_flash(:info, "You must join ShlinkedIn to do that :)")
     |> push_patch(to: socket.assigns.return_to)}
  end

  def handle_event("toggle-share-menu", _, socket) do
    socket = assign(socket, show_share_menu: !socket.assigns.show_share_menu)
    {:noreply, socket}
  end

  def handle_event("new-comment", %{"id" => id}, %{assigns: %{return_to: return_to}} = socket) do
    case return_to do
      "/" -> {:noreply, push_patch(socket, to: "/home/posts/#{id}/new_comment")}
      other -> {:noreply, push_patch(socket, to: other <> "/posts/#{id}/new_comment")}
    end
  end

  def handle_event("toggle-post-options", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_post_options: !socket.assigns.show_post_options
    )

    {:noreply, socket}
  end

  def handle_event("pin-post", _params, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        pinned: true
      })

    socket =
      socket
      |> put_flash(:info, "Post pinned!")
      |> push_redirect(to: "/home")

    {:noreply, socket}
  end

  def handle_event("unpin-post", _params, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        pinned: false
      })

    socket =
      socket
      |> put_flash(:info, "Post unpinned")
      |> push_redirect(to: "/home")

    {:noreply, socket}
  end

  def handle_event("feature-post", _params, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)
    poster = Shlinkedin.Profiles.get_profile_by_profile_id(socket.assigns.post.profile_id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        featured: true,
        featured_date: NaiveDateTime.utc_now()
      })
      |> Shlinkedin.Profiles.ProfileNotifier.observer(:featured_post, %Profile{id: 3}, poster)

    socket =
      socket
      |> put_flash(:info, "Post featured!")
      |> push_redirect(to: "/home")

    {:noreply, socket}
  end

  def handle_event("unfeature-post", _, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        featured: false
      })

    socket =
      socket
      |> put_flash(:info, "Post un-featured!")
      |> push_redirect(to: "/home")

    {:noreply, socket}
  end

  def handle_event("hide-post-options", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_post_options: false,
      show_share_menu: false
    )

    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_like(socket.assigns.profile, socket.assigns.post, like_type)

    send_update(ShlinkedinWeb.PostLive.PostLikes,
      id: socket.assigns.post.id,
      spin: true
    )

    send_update_after(
      ShlinkedinWeb.PostLive.PostLikes,
      [id: socket.assigns.post.id, spin: false],
      1000
    )

    {:noreply, socket}
  end

  defp featured_post_header(assigns, post) do
    ~L"""
        <%# Post of Day tag %>
        <%= if post.featured do %>
        <span
            class="bg-white absolute rounded-full r top-1 right-1 inline-flex items-center px-1 py-0.5 text-xs font-medium text-yellow-500">


            <%= if post.featured_date != nil do %>
            <span class="italic pr-1">Featured</span>
            <% end %>

            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd"
                    d="M5 2a1 1 0 011 1v1h1a1 1 0 010 2H6v1a1 1 0 01-2 0V6H3a1 1 0 010-2h1V3a1 1 0 011-1zm0 10a1 1 0 011 1v1h1a1 1 0 110 2H6v1a1 1 0 11-2 0v-1H3a1 1 0 110-2h1v-1a1 1 0 011-1zM12 2a1 1 0 01.967.744L14.146 7.2 17.5 9.134a1 1 0 010 1.732l-3.354 1.935-1.18 4.455a1 1 0 01-1.933 0L9.854 12.8 6.5 10.866a1 1 0 010-1.732l3.354-1.935 1.18-4.455A1 1 0 0112 2z"
                    clip-rule="evenodd"></path>
            </svg>
        </span>
        <% end %>
    """
  end

  defp pinned_post_header(assigns, post) do
    ~L"""
        <%# Pinned %>
        <%= if post.pinned do %>
        <span
            class="bg-white absolute rounded-full r top-1 right-1 inline-flex items-center px-1 py-0.5 text-xs font-medium text-blue-500">


            <span class="italic pr-1">Pinned</span>

            📌
        </span>
        <% end %>
    """
  end

  defp censor_tag(assigns, post) do
    ~L"""
    <%= if post.censor_tag == true do %>
    <div>
        <div class="rounded-md bg-blue-50 p-4">
            <div class="flex">
                <div class="flex-shrink-0">
                    <!-- Heroicon name: information-circle -->
                    <svg class="h-5 w-5 text-blue-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"
                        fill="currentColor" aria-hidden="true">
                        <path fill-rule="evenodd"
                            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                            clip-rule="evenodd" />
                    </svg>
                </div>
                <div class="ml-3 flex-1 md:flex md:justify-between">
                    <p class="text-sm text-blue-700">
                        <%= post.censor_body %>
                    </p>
                </div>
            </div>
        </div>
    </div>
    <% end %>
    """
  end

  defp like_map_list(like_map) do
    Enum.filter(like_map, fn {_, d} -> d.active end) |> Enum.map(fn {_, d} -> d end)
  end

  defp get_prompt() do
    Timeline.get_random_prompt()
  end

  defp tweet_intent(prompt, url) do
    "https://twitter.com/intent/tweet?text=#{prompt.text}&url=#{url}&hashtags=#{prompt.hashtags}"
  end

  defp profile_allowed_to_delete_post?(profile, post) do
    Timeline.profile_allowed_to_delete_post?(profile, post)
  end

  defp profile_allowed_to_edit_post?(profile, post) do
    Timeline.profile_allowed_to_edit_post?(profile, post)
  end

  defp is_admin?(profile) do
    Shlinkedin.Profiles.is_admin?(profile)
  end

  defp is_moderator?(profile) do
    Shlinkedin.Profiles.is_moderator?(profile)
  end

  defp get_num_reaction_likes(
         nil,
         %Timeline.Post{},
         _like
       ) do
    0
  end

  defp get_num_reaction_likes(
         %Profile{} = profile,
         %Timeline.Post{} = post,
         like
       ) do
    if Ecto.assoc_loaded?(post.likes) do
      Enum.filter(post.likes, fn l ->
        l.profile_id == profile.id && l.like_type == like.like_type
      end)
      |> length()
    else
      0
    end
  end
end
