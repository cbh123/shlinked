defmodule ShlinkedinWeb.PostView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.PostView

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{
      body: post.body,
      photo_urls: post.photo_urls,
      gif_url: post.gif_url,
      featured: post.featured,
      pinned: post.pinned,
      updated_at: post.updated_at
    }
  end
end
