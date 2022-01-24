defmodule ShlinkedinWeb.ContentLive.Show do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.News

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    content = News.get_content!(id)

    {:noreply,
     socket
     |> assign(:page_title, content.title)
     |> assign(:content, content)
     |> assign(meta_attrs: meta_attrs(content.title, content.author, content.header_image))}
  end

  def is_allowed?(profile) do
    Shlinkedin.Profiles.is_admin?(profile)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket = check_access(socket, Routes.content_index_path(socket, :index))

    content = News.get_content!(id)
    News.delete_content(socket.assigns.profile, content)

    {:noreply,
     socket
     |> push_redirect(to: Routes.content_index_path(socket, :index))
     |> put_flash(:info, "Successfully deleted")}
  end

  defp tweet_intent(headline, url) do
    "https://twitter.com/intent/tweet?text=#{headline}&url=#{url}"
  end

  defp linkedin_intent(id) do
    "https://www.linkedin.com/sharing/share-offsite/?url=https://shlinkedin.com/content/show/#{id}"
  end

  defp meta_attrs(_text, name, image) do
    [
      %{
        property: "og:image",
        content: image
      },
      %{
        propoert: "og:description",
        content: "A ShlinkedIn article by #{name}"
      },
      %{
        name: "twitter:image:src",
        content: image
      },
      %{
        property: "og:image:height",
        content: "630"
      },
      %{
        property: "og:image:width",
        content: "1200"
      }
    ]
  end
end
