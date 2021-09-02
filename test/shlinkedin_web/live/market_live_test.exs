defmodule ShlinkedinWeb.MarketLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_user_and_profile

  test "initial render", %{conn: conn, profile: _profile} do
    {:ok, view, _html} = conn |> live("/market")

    assert render(view) =~ "ShlinkMarket"
  end

  test "create an ad", %{conn: conn, profile: profile} do
    {:ok, view, _html} = conn |> live("/market")

    assert view |> element("a", "New Ad") |> render_click() =~
             "Create an Ad"

    assert_patch(view, Routes.market_index_path(conn, :new_ad))

    # at first add gif doens't work
    assert view |> element("#add-gif") |> render_click() =~ "Pls enter a product name first!"
    assert view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat"}) =~ "Snapchat"

    # check that changing price changes cost to create
    assert view |> form("#ad-form") |> render_change(ad: %{price: Money.new(30000, :SHLINK)}) =~
             "75.00"

    assert view |> form("#ad-form") |> render_change(ad: %{price: Money.new(25000, :SHLINK)}) =~
             "62.50"

    assert profile.points.amount == 100

    view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat"})
    view |> element("#add-gif") |> render_click()

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
    {:ok, _view, _html} = conn |> live("/market")
  end

  test "ad with zero quantity is sold out", %{conn: conn, profile: _profile} do
    {:ok, _view, _html} = conn |> live("/market")
  end

  test "click show_sold toggle includes sold ads", %{conn: conn, profile: profile} do
    {:ok, view, _html} = conn |> live("/market")

    assert profile.show_sold_ads == false

    view |> element("#toggle-sold") |> render_click()

    updated_profile = Shlinkedin.Profiles.get_profile_by_profile_id(profile.id)
    assert updated_profile.show_sold_ads == true
  end

  # test "click on ad goes to ad show page", %{conn: conn, profile: _profile} do
  #   # {:ok, _view, _html} = conn |> live("/market")

  #   # {:ok, _, html} = view |> element("#ad-image-#{")
  #   #   |> form("#post-form", post: @create_attrs)
  #   #   |> render_submit()
  #   #   |> follow_redirect(conn, Routes.home_index_path(conn, :index))
  # end
end
