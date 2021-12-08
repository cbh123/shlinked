defmodule ShlinkedinWeb.ResumeLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline.Generators

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(meta_attrs: meta_attrs())
     |> assign(page_title: "Check out my new resume!")}
  end

  def handle_event("save-to-profile", _, socket) do
    {:ok, profile} =
      Shlinkedin.Profiles.update_profile(socket.assigns.profile, %{
        resume_link: socket.assigns.url
      })

    {:noreply,
     socket
     |> put_flash(:info, "Saved new resume")
     |> push_redirect(to: Routes.profile_show_path(socket, :show, profile.slug))}
  end

  @impl true
  def handle_params(
        %{
          "name" => name,
          "address" => _address,
          "education" => _education,
          "major" => _major,
          "gpa" => _gpa,
          "summary" => _summary,
          "company1_name" => _company1_name,
          "company1_title" => _company1_title,
          "company1_job" => _company1_job,
          "company2_name" => _company2_name,
          "company2_title" => _company2_title,
          "company2_job" => _company2_job,
          "company3_name" => _company3_name,
          "company3_title" => _company3_title,
          "company3_job" => _company3_job,
          "hobbies" => _hobbies,
          "reference" => _references
        } = params,
        url,
        socket
      ) do
    params = params |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    socket =
      socket
      |> assign(params)
      |> assign(url: url)
      |> assign(created: true)
      |> assign(page_title: "Check out #{name}'s resume")

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp meta_attrs() do
    [
      %{
        property: "og:image",
        content: "https://media.istockphoto.com/photos/resume-picture-id1227223328"
      },
      %{
        name: "twitter:image:src",
        content: "https://media.istockphoto.com/photos/resume-picture-id1227223328"
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
