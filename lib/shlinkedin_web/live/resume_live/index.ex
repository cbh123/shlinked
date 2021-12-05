defmodule ShlinkedinWeb.ResumeLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline.Generators

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(page_title: "ShlinkedIn Resume Generator") |> assign(create_resume())}
  end

  @impl true
  def handle_event("create-resume", _, socket) do
    socket = assign(socket, create_resume())
    {:noreply, socket}
  end

  def create_resume() do
    company_name1 = Generators.company_name()
    company_name2 = Generators.company_name()
    company_name3 = Generators.company_name()

    %{
      name: "John",
      address: Generators.address(),
      contact: "profile_link",
      education: Generators.institution(),
      major: Generators.major(),
      gpa: Generators.gpa(),
      company1_name: company_name1,
      company1_summary: Generators.company_summary(company_name1),
      company1_title: Generators.job_title(),
      company1_job: Generators.job_description(),
      company2_name: company_name2,
      company2_summary: Generators.company_summary(company_name2),
      company2_title: Generators.job_title(),
      company2_job: Generators.job_description(),
      company3_name: company_name3,
      company3_summary: Generators.company_summary(company_name3),
      company3_title: Generators.job_title(),
      company3_job: Generators.job_description(),
      hobbies: Generators.hobbies(),
      reference: Generators.reference()
    }
  end
end
