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
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    if connected?(socket) do
      Timeline.subscribe()
      News.subscribe()
    end

    feed_options = %{
      type: socket.assigns.profile.feed_type,
      time: socket.assigns.profile.feed_time
    }

    {:ok,
     socket
     |> assign(
       update_action: "append",
       feed_options: feed_options,
       page: 1,
       per_page: 5,
       right_lower_box: load_activity_or_sponsor?(),
       stories: Timeline.list_stories(),
       headline_page: 1,
       headline_per_page: 15,
       like_map: Timeline.like_map(),
       comment_like_map: Timeline.comment_like_map(),
       num_show_comments: 1
     )
     |> fetch_headlines()
     |> fetch_profile_related_data()
     |> fetch_posts(), temporary_assigns: [posts: [], articles: []]}
  end

  defp fetch_profile_related_data(%{assigns: %{profile: nil}} = socket) do
    assign(
      socket,
      checklist: nil,
      my_groups: [],
      show_discord_alert: false
    )
  end

  defp fetch_profile_related_data(%{assigns: %{profile: profile}} = socket) do
    assign(
      socket,
      checklist: Shlinkedin.Levels.get_current_checklist(profile, socket),
      my_groups: Groups.list_profile_groups(profile),
      show_discord_alert: !profile.joined_discord
    )
  end

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

  defp fetch_headlines(%{assigns: %{headline_page: page, headline_per_page: per_page}} = socket) do
    articles = News.list_articles(paginate: %{page: page, per_page: per_page})
    assign(socket, articles: articles)
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
    {:noreply,
     socket |> assign(headline_page: socket.assigns.headline_page + 1) |> fetch_headlines()}
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

  def handle_event("close-discord", _, socket) do
    socket = assign(socket, show_discord_alert: false)
    {:noreply, socket}
  end

  def handle_event("join-discord", _, %{assigns: %{profile: profile}} = socket) do
    {:ok, profile} = Profiles.update_profile(profile, %{"joined_discord" => true})
    {:ok, _txn} = Shlinkedin.Points.point_observer(profile, :join_discord)

    socket =
      socket |> assign(profile: profile) |> redirect(external: "https://discord.gg/BkQGryuGjn")

    {:noreply, socket}
  end

  def handle_event("already-discord", _, %{assigns: %{profile: profile}} = socket) do
    {:ok, profile} = Profiles.update_profile(profile, %{"joined_discord" => true})
    {:ok, _txn} = Shlinkedin.Points.point_observer(profile, :join_discord)

    socket =
      socket
      |> assign(profile: profile, show_discord_alert: false)
      |> put_flash(:info, "Thank you for serving the cause. +100 SP")

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

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp load_activity_or_sponsor?() do
    [
      %{type: :sponsor, content: "Pickle Hot Sauce"}
    ]
    |> Enum.at(0)
  end
end
