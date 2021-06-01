defmodule ShlinkedinWeb.ErrorView do
  use ShlinkedinWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # def render("404.html.eex", assigns) do
  #   render("404.html", assigns)
  # end

  # def render("500.html.eex", _assigns) do
  #   "Server internal error"
  # end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found("404.html.eex", assigns) do
    IO.inspect(assigns, label: "")
    render("404.html.leex", assigns)
  end
end
