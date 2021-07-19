defmodule ShlinkedinWeb.MarketLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_user_and_profile

  test "initial render", %{conn: conn, profile: _profile} do
    {:ok, view, _html} = conn |> live("/marketplace")

    assert render(view) =~ "ShlinkMarket"
  end

  test "create an ad", %{conn: conn, profile: profile} do
    {:ok, view, _html} = conn |> live("/marketplace")

    assert view |> element("a", "New Ad") |> render_click() =~
             "Create an Ad"

    assert_patch(view, Routes.market_index_path(conn, :new_ad))

    # at first add gif doens't work
    assert view |> element("#add-gif") |> render_click() =~ "Pls enter a product name first!"
    assert view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat"}) =~ "Snapchat"

    # check that changing price changes cost to create
    assert view |> form("#ad-form") |> render_change(ad: %{price: Money.new(30000, :SHLINK)}) =~
             "150.00"

    assert view |> form("#ad-form") |> render_change(ad: %{price: Money.new(25000, :SHLINK)}) =~
             "125.00"

    assert profile.points.amount == 100

    view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat"})
    view |> element("#add-gif") |> render_click()

    assert view
           |> form("#ad-form",
             ad: %{
               body: "micromisoft",
               product: "snapchat"
             }
           )
           |> render_submit() =~ "be blank"

    {:ok, view, html} =
      view
      |> form("#ad-form",
        ad: %{
          body: "micromisoft"
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
