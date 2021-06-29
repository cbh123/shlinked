defmodule ShlinkedinWeb.HomeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_user_and_profile

  test "initial render", %{conn: conn, profile: _profile} do
    {:ok, view, _html} = conn |> live("/marketplace")

    assert render(view) =~ "ShlinkMarket"
  end

  test "create an ad", %{conn: conn, profile: profile} do
    {:ok, view, _html} = conn |> live("/home")

    assert view |> element("a", "Create Ad") |> render_click() =~
             "Create Ad"

    assert_patch(view, Routes.home_index_path(conn, :new_ad))

    # check that changing quantity changes cost to create
    view |> form("#ad-form") |> render_change(%{quantity: 5}) =~ "125.0"
    view |> form("#ad-form") |> render_change(%{quantity: 2, price: "1000"}) =~ "500.0"
    assert profile.points == 100

    {:ok, view, html} =
      view
      |> form("#ad-form",
        ad: %{
          body: "micromisoft",
          company: "facebook",
          product: "computer",
          quantity: 5,
          price: "1000"
        }
      )
      |> render_submit()
      |> follow_redirect(conn)

    # todo: make sure profiles points go down!

    assert html =~ "Ad created successfully"
    assert html =~ "ShlinkMarket"
  end

  test "click on ad to buy", %{conn: conn, profile: _profile} do
    {:ok, view, _html} = conn |> live("/marketplace")
  end

  test "ad with zero quantity is sold out", %{conn: conn, profile: _profile} do
    {:ok, view, _html} = conn |> live("/marketplace")
  end

  # test "click on ad goes to ad show page", %{conn: conn, profile: _profile} do
  #   # {:ok, view, _html} = conn |> live("/marketplace")

  #   # {:ok, _, html} = view |> element("#ad-image-#{")
  #   #   |> form("#post-form", post: @create_attrs)
  #   #   |> render_submit()
  #   #   |> follow_redirect(conn, Routes.home_index_path(conn, :index))
  # end
end
