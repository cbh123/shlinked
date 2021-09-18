defmodule ShlinkedinWeb.ShowHomeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.TimelineFixtures

  setup do
    post = post_fixture()
    %{post: post}
  end

  describe "View post as a profile" do
    setup :register_user_and_profile

    test "render show post page", %{conn: conn, post: post} do
      {:ok, _view, html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      assert html =~ post.body
      assert html =~ post.profile.persona_name
    end

    test "render show post page with no body text", %{conn: conn} do
      post = post_fixture(%{"body" => ""})
      {:ok, _view, html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      assert html =~ post.profile.persona_name
    end

    test "like a post", %{conn: conn, post: post} do
      {:ok, view, _html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      view |> element("#post-#{post.id}-like-Milk") |> render_click()

      assert view |> element("#post-likes-#{post.id}") |> render() =~ "4 • 4 people"

      view
      |> element("#post-likes-#{post.id}")
      |> render_click() =~
        "Reactions"

      assert view |> render() =~ "Milk"
    end

    test "write comment", %{conn: conn, profile: _profile, post: post} do
      {:ok, view, _html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      view
      |> element("#new-comment-#{post.id}")
      |> render_click()

      assert view |> element("#first-comment-btn-#{post.id}") |> render_click() =~
               "Add a comment..."

      assert_patch(view, Routes.home_show_path(conn, :new_comment, post.id))

      view |> element("#first-comment-btn-#{post.id}") |> render_click()

      view
      |> form("#comment-form", comment: %{body: "yay first comment!"})
      |> render_submit()

      assert view |> render() =~ "yay first comment!"
      assert view |> render() =~ "you commented! +1 shlink points"
    end
  end

  describe "View post as ANONYMOUS" do
    test "render show post page", %{conn: conn, post: post} do
      {:ok, _view, html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      assert html =~ post.body
      assert html =~ post.profile.persona_name
    end

    test "like a post", %{conn: conn, post: post} do
      {:ok, view, _html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      view |> element("#post-#{post.id}-like-Milk") |> render_click()

      assert_patch(view, Routes.home_show_path(conn, :show, post.id))
      assert view |> render() =~ "You must join"

      view
      |> element("#post-likes-#{post.id}")
      |> render_click() =~
        "Reactions"

      assert view |> render() =~ "You must join"
    end

    test "comment on a post", %{conn: conn, post: post} do
      {:ok, view, _html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      view |> element("#new-comment-#{post.id}") |> render_click()

      assert_patch(view, Routes.home_show_path(conn, :show, post.id))
      assert view |> render() =~ "You must join"
    end
  end
end
