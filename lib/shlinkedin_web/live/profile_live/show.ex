defmodule ShlinkedinWeb.ProfileLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Accounts

  def mount(%{"slug" => slug}, _session, socket) do
    profile = Accounts.get_profile_by_slug(slug)
    {:ok, socket |> assign(:profile, profile)}
  end
end
