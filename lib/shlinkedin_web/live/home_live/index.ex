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

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
      News.subscribe()
    end

    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(
       update_action: "append",
       feed_type: "all",
       page: 1,
       per_page: 10,
       activities: Timeline.list_unique_notifications(60),
       articles: News.list_top_articles(15),
       featured_profiles: Profiles.list_random_profiles(3),
       random_groups: Groups.list_random_groups(5),
       like_map: Timeline.like_map(),
       comment_like_map: Timeline.comment_like_map(),
       num_show_comments: 1
     )
     |> fetch_posts(), temporary_assigns: [posts: [], articles: []]}
  end

  defp fetch_posts(
         %{assigns: %{profile: profile, feed_type: feed_type, page: page, per_page: per}} = socket
       ) do
    assign(socket,
      posts:
        Timeline.list_posts(
          profile,
          [paginate: %{page: page, per_page: per}],
          feed_type
        )
    )
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

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(update_action: "append", page: assigns.page + 1) |> fetch_posts()}
  end

  def handle_event("more-headlines", _, socket) do
    {:noreply, socket |> assign(articles: News.list_random_articles(5))}
  end

  def handle_event("change-feed", %{"feed" => feed}, socket) do
    case feed do
      "friends" ->
        {:noreply,
         socket |> assign(update_action: "replace", feed_type: "friends") |> fetch_posts}

      "featured" ->
        {:noreply,
         socket |> assign(update_action: "replace", feed_type: "featured") |> fetch_posts}

      _ ->
        {:noreply, socket |> assign(update_action: "replace", feed_type: "all") |> fetch_posts}
    end
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
  def handle_info({:post_created, post}, socket) do
    socket = assign(socket, update_action: "prepend")
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    socket = assign(socket, update_action: "append")
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:article_updated, article}, socket) do
    {:noreply, update(socket, :articles, fn articles -> [article | articles] end)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:article_deleted, article}, socket) do
    {:noreply, update(socket, :articles, fn articles -> [article | articles] end)}
  end
end
