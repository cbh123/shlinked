defmodule ShlinkedinWeb.ProfileControllerTest do
  use ShlinkedinWeb.ConnCase

  alias Shlinkedin.Profiles.Profile
  import Shlinkedin.ProfilesFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), profile: profile_fixture()}
  end

  describe "show_profile" do
    # test "shows profile data", %{conn: conn, profile: %Profile{slug: slug, id: id}} do
    #   conn = get(conn, Routes.profile_path(conn, :show, slug))
    #   assert %{"id" => ^id} = json_response(conn, 200)["data"]
    # end
  end
end
