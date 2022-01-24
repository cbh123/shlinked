defmodule ShlinkedinWeb.ResumeLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline.Generators

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(meta_attrs: meta_attrs())
     |> assign(
       page_title: "Try the ShlinkedIn Resume Generator",
       created: false,
       spin: false,
       confetti: false,
       name: name(socket.assigns.profile)
     )}
  end

  defp name(nil), do: ""
  defp name(profile), do: profile.persona_name

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

  @impl true
  def handle_info(:stop_spin, socket) do
    {:noreply, socket |> assign(spin: false, confetti: true)}
  end

  def handle_event("share-resume", _, socket) do
    socket =
      socket
      |> push_redirect(
        to:
          Routes.resume_show_path(socket, :show,
            name: socket.assigns.name,
            photo: socket.assigns.photo,
            address: socket.assigns.address,
            education: socket.assigns.education,
            major: socket.assigns.major,
            gpa: socket.assigns.gpa,
            summary: socket.assigns.summary,
            company1_name: socket.assigns.company1_name,
            company1_title: socket.assigns.company1_title,
            company1_job: socket.assigns.company1_job,
            company2_name: socket.assigns.company2_name,
            company2_title: socket.assigns.company2_title,
            company2_job: socket.assigns.company2_job,
            company3_name: socket.assigns.company3_name,
            company3_title: socket.assigns.company3_title,
            company3_job: socket.assigns.company3_job,
            hobbies: socket.assigns.hobbies,
            reference: socket.assigns.reference
          )
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("change-name", %{"name" => name}, socket) do
    socket = assign(socket, name: name)
    {:noreply, socket}
  end

  @impl true
  def handle_event("create-resume", _, socket) do
    company_name1 = Generators.company_name()
    company_name2 = Generators.company_name()
    company_name3 = Generators.company_name()

    Process.send_after(self(), :stop_spin, 1000)

    socket =
      socket
      |> assign(spin: true, confetti: false, created: true)
      |> assign(
        name: socket.assigns.name,
        photo: Generators.profile_photo(),
        address: Generators.address(),
        education: Generators.institution(),
        major: Generators.major(),
        gpa: Generators.gpa(),
        summary: Generators.summary(),
        company1_name: company_name1,
        company1_title: Generators.job_title(),
        company1_job: Generators.job_description(),
        company2_name: company_name2,
        company2_title: Generators.job_title(),
        company2_job: Generators.job_description(),
        company3_name: company_name3,
        company3_title: Generators.job_title(),
        company3_job: Generators.job_description(),
        hobbies: Generators.hobbies(),
        reference: Generators.reference()
      )

    {:noreply, socket}
  end
end
