defmodule ShlinkedinWeb.TestimonialView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.TestimonialView

  def render("show.json", %{testimonial: testimonial}) do
    %{data: render_one(testimonial, TestimonialView, "testimonial.json")}
  end

  def render("testimonial.json", %{testimonial: testimonial}) do
    from_profile_name =
      Shlinkedin.Profiles.get_profile_by_profile_id(testimonial.from_profile_id).persona_name

    %{
      body: testimonial.body,
      rating: testimonial.rating,
      from_profile: from_profile_name,
      updated_at: testimonial.updated_at
    }
  end
end
