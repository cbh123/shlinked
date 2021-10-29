defmodule ShlinkedinWeb.EndorsementView do
  use ShlinkedinWeb, :view
  alias ShlinkedinWeb.EndorsementView

  def render("show.json", %{endorsement: endorsement}) do
    %{data: render_one(endorsement, EndorsementView, "endorsement.json")}
  end

  def render("endorsement.json", %{endorsement: endorsement}) do
    from_profile_name =
      Shlinkedin.Profiles.get_profile_by_profile_id(endorsement.from_profile_id).persona_name

    %{
      body: endorsement.body,
      from_profile: from_profile_name,
      updated_at: endorsement.updated_at
    }
  end
end
