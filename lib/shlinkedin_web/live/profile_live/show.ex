defmodule ShlinkedinWeb.ProfileLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Accounts

  def mount(%{"slug" => slug}, session, socket) do
    show_profile = Accounts.get_profile_by_slug(slug)

    {:ok, assign(is_user(session, socket), show_profile: show_profile)}
  end
end
