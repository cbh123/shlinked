defmodule ShlinkedinWeb.HomeLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Profiles
  alias Shlinkedin.Groups
  alias Shlinkedin.Timeline.{Post, Comment, Story}
  alias Shlinkedin.News
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Ads
  alias Shlinkedin.News.Article
  require Integer

  @impl true
  def mount(params, session, socket) do
    socket = is_user(session, socket)

    if connected?(socket) do
      Timeline.subscribe()
      News.subscribe()
    end

    feed_options = %{type: check_feed_type(params["type"]), time: check_feed_time(params["time"])}

    {:ok,
     socket
     |> assign(
       update_action: "append",
       feed_options: feed_options,
       page: 1,
       per_page: 5,
       activities: Timeline.list_unique_notifications(60),
       stories: Timeline.list_stories(),
       articles: News.list_top_articles(15),
       like_map: Timeline.like_map(),
       comment_like_map: Timeline.comment_like_map(),
       num_show_comments: 1
     )
     |> fetch_profile_related_data()
     |> map_story_id_to_seen_all_stories()
     |> fetch_posts(), temporary_assigns: [posts: [], articles: []]}
  end

  defp fetch_profile_related_data(%{assigns: %{profile: nil}} = socket) do
    assign(
      socket,
      checklist: nil,
      my_groups: []
    )
  end

  defp fetch_profile_related_data(socket) do
    assign(
      socket,
      checklist: Shlinkedin.Levels.get_current_checklist(socket.assigns.profile, socket),
      my_groups: Groups.list_profile_groups(socket.assigns.profile)
    )
  end

  defp check_feed_type(nil), do: "reactions"
  defp check_feed_type(type), do: type

  defp check_feed_time(nil), do: "week"
  defp check_feed_time(type), do: type

  defp fetch_posts(
         %{
           assigns: %{
             profile: %{ad_frequency: ad_frequency} = profile,
             feed_options: feed_options,
             page: page,
             per_page: per
           }
         } = socket
       ) do
    # get posts and convert a %{type: "post", content: post} format
    posts =
      Timeline.list_posts(profile, [paginate: %{page: page, per_page: per}], feed_options)
      |> Enum.map(fn c -> %{type: "post", content: c} end)

    content =
      Enum.with_index(posts)
      |> Enum.map(fn {post, index} ->
        cond do
          rem(index, ad_frequency) == 0 and page != 1 ->
            [get_ad(), post]

          index == 3 ->
            [%{type: "featured_profiles", content: Profiles.list_random_profiles(3)}, post]

          index == 5 ->
            [%{type: "featured_groups", content: Groups.list_random_groups(5)}, post]

          index == 2 and page == 1 ->
            [get_ad(), post]

          true ->
            post
        end
      end)
      |> List.flatten()

    assign(socket,
      posts: content
    )
  end

  defp get_ad() do
    %{type: "ad", content: Ads.get_random_ad()}
  end

  def handle_params(%{"type" => type, "time" => time} = params, _url, socket) do
    {:ok, _profile} =
      Profiles.update_profile(socket.assigns.profile, %{feed_type: type, feed_time: time})

    socket =
      socket
      |> assign(update_action: "replace", page: 1, feed_options: %{type: type, time: time})
      |> fetch_posts()

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Create a post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :new_story, _params) do
    socket
    |> assign(:page_title, "💥 ShlinkBlast Mission Control")
    |> assign(:story, %Story{})
  end

  defp apply_action(socket, :new_comment, %{"id" => id, "reply_to" => username}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reply to #{post.profile.persona_name}'s comment")
    |> assign(:reply_to, username)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_comment, %{"id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Comment")
    |> assign(:reply_to, nil)
    |> assign(:comments, [])
    |> assign(:comment, %Comment{})
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_article, _params) do
    socket
    |> assign(:page_title, "New Headline")
    |> assign(:article, %Article{})
  end

  defp apply_action(socket, :new_ad, _params) do
    socket
    |> assign(:page_title, "Create an Ad")
    |> assign(:ad, %Ad{})
  end

  defp apply_action(socket, :edit_ad, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ad")
    |> assign(:ad, Ads.get_ad_preload_profile!(id))
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

  defp apply_action(socket, :show_likes, %{"id" => id}) do
    post = Timeline.get_post_preload_profile(id)

    socket
    |> assign(:page_title, "Reactions")
    |> assign(
      :grouped_likes,
      Timeline.list_likes(post)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
  end

  defp apply_action(socket, :show_comment_likes, %{"comment_id" => comment_id}) do
    comment = Timeline.get_comment!(comment_id)

    socket
    |> assign(:page_title, "Comment Reactions")
    |> assign(
      :grouped_likes,
      Timeline.list_comment_likes(comment)
      |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
    )
    |> assign(:comment, comment)
  end

  defp apply_action(socket, :new_invite, _params) do
    socket
    |> assign(:invite, %Shlinkedin.Profiles.Invite{})
    |> assign(:page_title, "Invite to ShlinkedIn")
  end

  defp apply_action(socket, :new_feedback, _params) do
    socket
    |> assign(:feedback, %Shlinkedin.Feedback.Feedback{})
    |> assign(:page_title, "Feedback")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ShlinkedIn")
    |> assign(:post, nil)
  end

  def handle_event("sort-feed", %{"type" => type, "time" => time}, socket) do
    {:noreply,
     socket |> push_patch(to: Routes.home_index_path(socket, :index, type: type, time: time))}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(update_action: "append", page: assigns.page + 1) |> fetch_posts()}
  end

  def handle_event("more-headlines", _, socket) do
    {:noreply, socket |> assign(articles: News.list_random_articles(5))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, socket |> fetch_posts()}
  end

  def handle_event("delete-comment", %{"id" => id}, socket) do
    comment = Timeline.get_comment!(id)
    {:ok, _} = Timeline.delete_comment(comment)

    {:noreply,
     socket
     |> put_flash(:info, "Comment deleted")
     |> push_redirect(to: Routes.home_index_path(socket, :index))}
  end

  @impl true
  def handle_event("delete-article", %{"id" => id}, socket) do
    article = News.get_article!(id)
    {:ok, _} = News.delete_article(article)

    {:noreply,
     socket
     |> put_flash(:info, "Headline deleted")
     |> push_redirect(to: Routes.home_index_path(socket, :index))}
  end

  @impl true
  def handle_event("delete-ad", %{"id" => id}, socket) do
    ad = Ads.get_ad!(id)
    {:ok, _} = Ads.delete_ad(ad)

    {:noreply,
     socket
     |> put_flash(:info, "Ad deleted")
     |> push_redirect(to: Routes.home_index_path(socket, :index))}
  end

  @impl true
  def handle_event("toggle-levels", _, %{assigns: %{profile: profile}} = socket) do
    {:ok, profile} = Profiles.update_profile(profile, %{"show_levels" => !profile.show_levels})

    socket = assign(socket, profile: profile)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    socket = assign(socket, update_action: "prepend")
    {:noreply, update(socket, :posts, fn posts -> [%{type: "post", content: post} | posts] end)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    socket = assign(socket, update_action: "append")
    {:noreply, update(socket, :posts, fn posts -> [%{type: "post", content: post} | posts] end)}
  end

  @impl true
  def handle_info({:article_updated, article}, socket) do
    {:noreply, update(socket, :articles, fn articles -> [article | articles] end)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [%{type: "post", content: post} | posts] end)}
  end

  @impl true
  def handle_info({:article_deleted, article}, socket) do
    {:noreply, update(socket, :articles, fn articles -> [article | articles] end)}
  end

  defp map_story_id_to_seen_all_stories(
         %{assigns: %{profile: %Profiles.Profile{id: nil}}} = socket
       ) do
    assign(socket, story_map: %{})
  end

  defp map_story_id_to_seen_all_stories(
         %{assigns: %{stories: stories, profile: profile}} = socket
       ) do
    story_map =
      stories
      |> Enum.map(fn s -> {s.id, Timeline.seen_all_stories?(profile, s.profile)} end)
      |> Map.new()

    assign(socket, story_map: story_map)
  end
end
