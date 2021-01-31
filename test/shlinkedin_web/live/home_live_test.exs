defmodule ShlinkedinWeb.HomeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Timeline
  alias Shlinkedin.Accounts

  import Shlinkedin.AccountsFixtures
  import Shlinkedin.ProfilesFixtures

  @create_attrs %{
    body: "some body"
  }

  setup %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> Map.replace!(:secret_key_base, ShlinkedinWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})
      |> log_in_user(user)
      |> ShlinkedinWeb.UserAuth.fetch_current_user([])

    %{user: user, profile: profile_fixture(user), conn: conn}
  end

  test "initial render with user and profile", %{conn: conn} do
    user = user_fixture()
    profile_fixture(user)

    {:ok, view, _html} =
      conn
      |> live("/home")

    assert render(view) =~ "Start a post"
  end

  describe "Index" do
    test "create new post and lists them", %{conn: conn, user: user, profile: profile} do
      {:ok, post} = Timeline.create_post(profile, @create_attrs, %Timeline.Post{})

      user_token = Accounts.generate_user_session_token(user)
      conn = conn |> put_session(:user_token, user_token)

      {:ok, _index_live, html} = live(conn, Routes.home_index_path(conn, :index))

      assert html =~ post.body
      assert html =~ "ShlinkNews"
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} =
        conn
        |> live(Routes.home_index_path(conn, :index))

      assert index_live |> element("a", "Start a post") |> render_click() =~
               "Create a post"

      assert_patch(index_live, Routes.home_index_path(conn, :new))

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.home_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some body"
    end

    test "deletes post", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      assert index_live |> element("#options-menu-#{post.id}") |> render_click()

      assert index_live |> element("#post-#{post.id} a", "Delete") |> render_click()

      refute index_live
             |> element("#post-#{post.id} a", "Delete")
             |> has_element?()
    end

    # add test for show likes
    # add test for like
    # add test for comment
    test "like post", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      assert index_live
             |> render_click(:like_selected, %{"phx-value-like-type:" "Pity"})
             |> IO.inspect()
    end
  end
end
