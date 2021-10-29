defmodule ShlinkedinWeb.ProfileControllerTest do
  use ShlinkedinWeb.ConnCase

  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile
  import Shlinkedin.ProfilesFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), profile: profile_fixture()}
  end

  describe "show_profile" do
    test "shows profile data", %{conn: conn, profile: %Profile{slug: slug} = profile} do
      conn = get(conn, Routes.profile_path(conn, :show, profile))
      assert %{"slug" => ^slug} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, profile: profile} do
      conn = get(conn, Routes.profile_path(conn, :show, "bloop"))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
