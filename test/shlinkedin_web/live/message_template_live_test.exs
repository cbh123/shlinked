defmodule ShlinkedinWeb.MessageTemplateLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Chat

  @create_attrs %{content: "some content", type: "some type"}
  @update_attrs %{content: "some updated content", type: "some updated type"}
  @invalid_attrs %{content: nil, type: nil}

  defp fixture(:message_template) do
    {:ok, message_template} = Chat.create_message_template(@create_attrs)
    message_template
  end

  defp create_message_template(_) do
    message_template = fixture(:message_template)
    %{message_template: message_template}
  end

  describe "Index" do
    setup [:create_message_template]

    test "lists all templates", %{conn: conn, message_template: message_template} do
      {:ok, _index_live, html} = live(conn, Routes.message_template_index_path(conn, :index))

      assert html =~ "Listing Templates"
      assert html =~ message_template.content
    end

    test "saves new message_template", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.message_template_index_path(conn, :index))

      assert index_live |> element("a", "New Message template") |> render_click() =~
               "New Message template"

      assert_patch(index_live, Routes.message_template_index_path(conn, :new))

      assert index_live
             |> form("#message_template-form", message_template: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#message_template-form", message_template: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.message_template_index_path(conn, :index))

      assert html =~ "Message template created successfully"
      assert html =~ "some content"
    end

    test "updates message_template in listing", %{conn: conn, message_template: message_template} do
      {:ok, index_live, _html} = live(conn, Routes.message_template_index_path(conn, :index))

      assert index_live |> element("#message_template-#{message_template.id} a", "Edit") |> render_click() =~
               "Edit Message template"

      assert_patch(index_live, Routes.message_template_index_path(conn, :edit, message_template))

      assert index_live
             |> form("#message_template-form", message_template: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#message_template-form", message_template: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.message_template_index_path(conn, :index))

      assert html =~ "Message template updated successfully"
      assert html =~ "some updated content"
    end

    test "deletes message_template in listing", %{conn: conn, message_template: message_template} do
      {:ok, index_live, _html} = live(conn, Routes.message_template_index_path(conn, :index))

      assert index_live |> element("#message_template-#{message_template.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#message_template-#{message_template.id}")
    end
  end

  describe "Show" do
    setup [:create_message_template]

    test "displays message_template", %{conn: conn, message_template: message_template} do
      {:ok, _show_live, html} = live(conn, Routes.message_template_show_path(conn, :show, message_template))

      assert html =~ "Show Message template"
      assert html =~ message_template.content
    end

    test "updates message_template within modal", %{conn: conn, message_template: message_template} do
      {:ok, show_live, _html} = live(conn, Routes.message_template_show_path(conn, :show, message_template))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Message template"

      assert_patch(show_live, Routes.message_template_show_path(conn, :edit, message_template))

      assert show_live
             |> form("#message_template-form", message_template: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#message_template-form", message_template: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.message_template_show_path(conn, :show, message_template))

      assert html =~ "Message template updated successfully"
      assert html =~ "some updated content"
    end
  end
end
