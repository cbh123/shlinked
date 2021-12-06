defmodule ShlinkedinWeb.ResumeLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline.Generators

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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
        _url,
        socket
      ) do
    params = params |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    socket =
      socket
      |> assign(params)
      |> assign(created: true)
      |> assign(page_title: "Check out #{name}'s resume")

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
