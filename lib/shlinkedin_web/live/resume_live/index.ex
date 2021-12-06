defmodule ShlinkedinWeb.ResumeLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline.Generators

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Try the ShlinkedIn Resume Generator",
       created: false,
       spin: false,
       confetti: false
     )}
  end

  @impl true
  def handle_params(
        %{
          "name" => _name,
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
        _url,
        socket
      ) do
    params = params |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    socket = socket |> assign(params) |> assign(created: true)
    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_info(:stop_spin, socket) do
    {:noreply, socket |> assign(spin: false, confetti: true)}
  end

  @impl true
  def handle_event("create-resume", _, socket) do
    company_name1 = Generators.company_name()
    company_name2 = Generators.company_name()
    company_name3 = Generators.company_name()

    Process.send_after(self(), :stop_spin, 1000)

    socket =
      socket
      |> assign(spin: true, confetti: false)
      |> push_patch(
        to:
          Routes.resume_index_path(socket, :index,
            name: Generators.full_name(),
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
      )

    {:noreply, socket}
  end
end
