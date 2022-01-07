defmodule ShlinkedinWeb.ContentLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.NewsFixtures

  @create_attrs %{author: "some author", content: "some content"}
  @update_attrs %{author: "some updated author", content: "some updated content"}
  @invalid_attrs %{author: nil, content: nil}

  defp create_content(_) do
    content = content_fixture()
    %{content: content}
  end

  describe "Index" do
    setup [:create_content]

    test "lists all content", %{conn: conn, content: content} do
      {:ok, _index_live, html} = live(conn, Routes.content_index_path(conn, :index))

      assert html =~ "Listing Content"
      assert html =~ content.author
    end

    test "saves new content", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.content_index_path(conn, :index))

      assert index_live |> element("a", "New Content") |> render_click() =~
               "New Content"

      assert_patch(index_live, Routes.content_index_path(conn, :new))

      assert index_live
             |> form("#content-form", content: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#content-form", content: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_index_path(conn, :index))

      assert html =~ "Content created successfully"
      assert html =~ "some author"
    end

    test "updates content in listing", %{conn: conn, content: content} do
      {:ok, index_live, _html} = live(conn, Routes.content_index_path(conn, :index))

      assert index_live |> element("#content-#{content.id} a", "Edit") |> render_click() =~
               "Edit Content"

      assert_patch(index_live, Routes.content_index_path(conn, :edit, content))

      assert index_live
             |> form("#content-form", content: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#content-form", content: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_index_path(conn, :index))

      assert html =~ "Content updated successfully"
      assert html =~ "some updated author"
    end

    test "deletes content in listing", %{conn: conn, content: content} do
      {:ok, index_live, _html} = live(conn, Routes.content_index_path(conn, :index))

      assert index_live |> element("#content-#{content.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#content-#{content.id}")
    end
  end

  describe "Show" do
    setup [:create_content]

    test "displays content", %{conn: conn, content: content} do
      {:ok, _show_live, html} = live(conn, Routes.content_show_path(conn, :show, content))

      assert html =~ "Show Content"
      assert html =~ content.author
    end

    test "updates content within modal", %{conn: conn, content: content} do
      {:ok, show_live, _html} = live(conn, Routes.content_show_path(conn, :show, content))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Content"

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
