defmodule ShlinkedinWeb.PostView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.PostView

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    post = Shlinkedin.Repo.preload(post, :profile)

    %{
      body: post.body,
      writer: post.profile.persona_name,
      photo_urls: post.photo_urls,
      gif_url: post.gif_url,
      featured: post.featured,
      pinned: post.pinned,
      updated_at: post.updated_at
    }
  end
end
