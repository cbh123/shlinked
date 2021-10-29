defmodule ShlinkedinWeb.HeadlineView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.HeadlineView

  def render("index.json", %{headlines: headlines}) do
    %{data: render_many(headlines, HeadlineView, "headline.json")}
  end

  def render("headline.json", %{headline: headline}) do
    %{
      headline: headline.headline,
      num_claps: length(headline.votes),
      updated_at: headline.updated_at
    }
  end
end
