defmodule ShlinkedinWeb.AwardTypeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Awards

  @create_attrs %{bg: "some bg", bg_hover: "some bg_hover", color: "some color", description: "some description", emoji: "some emoji", fill: "some fill", image_format: "some image_format", name: "some name", svg_path: "some svg_path"}
  @update_attrs %{bg: "some updated bg", bg_hover: "some updated bg_hover", color: "some updated color", description: "some updated description", emoji: "some updated emoji", fill: "some updated fill", image_format: "some updated image_format", name: "some updated name", svg_path: "some updated svg_path"}
  @invalid_attrs %{bg: nil, bg_hover: nil, color: nil, description: nil, emoji: nil, fill: nil, image_format: nil, name: nil, svg_path: nil}

  defp fixture(:award_type) do
    {:ok, award_type} = Awards.create_award_type(@create_attrs)
    award_type
  end

  defp create_award_type(_) do
    award_type = fixture(:award_type)
    %{award_type: award_type}
  end

  describe "Index" do
    setup [:create_award_type]

    test "lists all award_types", %{conn: conn, award_type: award_type} do
      {:ok, _index_live, html} = live(conn, Routes.award_type_index_path(conn, :index))

      assert html =~ "Listing Award types"
      assert html =~ award_type.bg
    end

    test "saves new award_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.award_type_index_path(conn, :index))

      assert index_live |> element("a", "New Award type") |> render_click() =~
               "New Award type"

      assert_patch(index_live, Routes.award_type_index_path(conn, :new))

      assert index_live
             |> form("#award_type-form", award_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#award_type-form", award_type: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.award_type_index_path(conn, :index))

      assert html =~ "Award type created successfully"
      assert html =~ "some bg"
    end

    test "updates award_type in listing", %{conn: conn, award_type: award_type} do
      {:ok, index_live, _html} = live(conn, Routes.award_type_index_path(conn, :index))

      assert index_live |> element("#award_type-#{award_type.id} a", "Edit") |> render_click() =~
               "Edit Award type"

      assert_patch(index_live, Routes.award_type_index_path(conn, :edit, award_type))

      assert index_live
             |> form("#award_type-form", award_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#award_type-form", award_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.award_type_index_path(conn, :index))

      assert html =~ "Award type updated successfully"
      assert html =~ "some updated bg"
    end

    test "deletes award_type in listing", %{conn: conn, award_type: award_type} do
      {:ok, index_live, _html} = live(conn, Routes.award_type_index_path(conn, :index))

      assert index_live |> element("#award_type-#{award_type.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#award_type-#{award_type.id}")
    end
  end

  describe "Show" do
    setup [:create_award_type]

    test "displays award_type", %{conn: conn, award_type: award_type} do
      {:ok, _show_live, html} = live(conn, Routes.award_type_show_path(conn, :show, award_type))

      assert html =~ "Show Award type"
      assert html =~ award_type.bg
    end

    test "updates award_type within modal", %{conn: conn, award_type: award_type} do
      {:ok, show_live, _html} = live(conn, Routes.award_type_show_path(conn, :show, award_type))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Award type"

      assert_patch(show_live, Routes.award_type_show_path(conn, :edit, award_type))

      assert show_live
             |> form("#award_type-form", award_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#award_type-form", award_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.award_type_show_path(conn, :show, award_type))

      assert html =~ "Award type updated successfully"
      assert html =~ "some updated bg"
    end
  end
end
