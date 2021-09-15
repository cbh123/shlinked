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

    test "like a post", %{conn: conn, post: post} do
      {:ok, view, _html} = live(conn, Routes.home_show_path(conn, :show, post.id))

      view |> element("#post-#{post.id}-like-Milk") |> render_click()

      assert view |> element("#post-likes-#{post.id}") |> render() =~ "1 • 1 person"

      view
      |> element("#post-likes-#{post.id}")
      |> render_click() =~
        "Reactions"

      assert view |> render() =~ "Milk"
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

      assert view |> element("#post-likes-#{post.id}") |> render() =~ "1 • 1 person"

      view
      |> element("#post-likes-#{post.id}")
      |> render_click() =~
        "Reactions"

      assert view |> render() =~ "Milk"
    end
  end
end
