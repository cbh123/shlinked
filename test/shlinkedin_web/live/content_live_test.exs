defmodule ShlinkedinWeb.ContentLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.NewsFixtures

  @create_attrs %{
    author: "some author",
    title: "some title",
    header_image: "link",
    topic: "hi"
  }
  @update_attrs %{author: "some updated author", title: "some updated title"}
  @invalid_attrs %{author: nil, title: nil}

  defp create_content(_) do
    content = content_fixture()
    %{content: content}
  end

  describe "Index REGULAR profile" do
    setup [:create_content, :register_user_and_profile]

    test "lists all content", %{conn: conn, content: content} do
      {:ok, _index_live, html} = live(conn, Routes.content_index_path(conn, :index))

      assert html =~ "ShlinkedIn Tribune"
      assert html =~ content.author
    end

    test "non admin profile tries to make content", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.content_index_path(conn, :index))

      refute index_live |> element("New Article") |> has_element?()
    end
  end

  describe "Index no profile" do
    setup [:create_content]

    test "lists all content", %{conn: conn, content: content} do
      {:ok, _index_live, html} = live(conn, Routes.content_index_path(conn, :index))

      assert html =~ "ShlinkedIn Tribune"
      assert html =~ content.author
    end
  end

  describe "Index ADMIN profile" do
    setup [:create_content, :register_user_and_admin_profile]

    test "saves new content", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.content_index_path(conn, :index))

      assert index_live |> element("a", "New Article") |> render_click() =~ "New Content"

      assert_patch(index_live, Routes.content_index_path(conn, :new))

      assert index_live
             |> form("#content-form", content: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#content-form", content: @create_attrs)
        |> render_submit(%{content: %{"content" => "some content"}})
        |> follow_redirect(conn, Routes.content_index_path(conn, :index))

      assert html =~ "Content created successfully"
      assert html =~ "some author"
    end
  end

  describe "Show as regular profile" do
    setup [:create_content, :register_user_and_profile]

    test "displays content", %{conn: conn, content: content} do
      {:ok, _show_live, html} = live(conn, Routes.content_show_path(conn, :show, content))

      assert html =~ content.title
      assert html =~ content.author
    end
  end

  describe "Show as admin" do
    setup [:create_content, :register_user_and_admin_profile]

    test "displays content", %{conn: conn, content: content} do
      {:ok, _show_live, html} = live(conn, Routes.content_show_path(conn, :show, content))

      assert html =~ content.author
    end

    test "updates content within modal", %{conn: conn, content: content} do
      {:ok, show_live, _html} = live(conn, Routes.content_show_path(conn, :show, content))

      assert show_live |> element("a", "Edit") |> render_click() =~ content.title

      assert_patch(show_live, Routes.content_show_path(conn, :edit, content))

      assert show_live
             |> form("#content-form", content: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#content-form", content: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_show_path(conn, :show, content))

      assert html =~ "Content updated successfully"
      assert html =~ "some updated author"
    end
  end
end
