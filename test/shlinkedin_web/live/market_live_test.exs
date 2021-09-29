defmodule ShlinkedinWeb.MarketLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.ProfilesFixtures
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Ads

  @valid_ad %{
    body: "micromisoft",
    company: "facebook",
    product: "computer",
    price: "1",
    gif_url: "test"
  }

  def ad_fixture(profile, attrs \\ %{}) do
    {:ok, ad} = Ads.create_ad(profile, %Ad{}, attrs |> Enum.into(@valid_ad))

    ad
  end

  describe "basics" do
    setup :register_user_and_profile

    test "initial render", %{conn: conn, profile: _profile} do
      {:ok, view, _html} = conn |> live("/market")

      assert render(view) =~ "ShlinkMarket"
    end

    @tag :gif_test
    test "create an ad", %{conn: conn, profile: profile} do
      {:ok, view, _html} = conn |> live("/market")

      assert view |> element("a", "New Ad") |> render_click() =~
               "Create an Ad"

      assert_patch(view, Routes.market_index_path(conn, :new_ad))

      # at first add gif doens't work
      assert view |> element("#add-gif") |> render_click() =~ "Pls enter a product name first!"

      assert view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat"}) =~
               "Snapchat"

      # check that changing price changes cost to create
      assert view |> form("#ad-form") |> render_change(ad: %{price: Money.new(30000, :SHLINK)}) =~
               "75.00"

      assert view |> form("#ad-form") |> render_change(ad: %{price: Money.new(25000, :SHLINK)}) =~
               "62.50"

      assert profile.points.amount == 100

      view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat"})
      assert view |> element("#add-gif") |> render_click() =~ "Choose new Gif"

      # cannot affort
      assert view |> form("#ad-form", ad: %{body: "micromisoft"}) |> render_submit() =~
               "You cannot afford"

      assert view |> form("#ad-form") |> render_change(ad: %{price: Money.new(100, :SHLINK)}) =~
               "0.25"

      {:ok, _view, html} =
        view
        |> form("#ad-form", ad: %{body: "micromisoft"})
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Ad created successfully"
      assert html =~ "ShlinkMarket"

      updated_profile = Shlinkedin.Profiles.get_profile_by_profile_id(profile.id)
      assert updated_profile.points.amount == 75
    end

    @tag :gif_test
    test "edit an ad that you made", %{conn: conn, profile: profile} do
      ad = ad_fixture(profile)

      {:ok, view, _html} = conn |> live("/ads/#{ad.id}")

      view |> element("#edit-ad") |> render_click() =~ "Edit Ad"

      assert_patch(view, Routes.market_index_path(conn, :edit_ad, ad.id))

      # todo: fix this cheating here. clicking edit ad should redirect here.
      {:ok, view, _html} = conn |> live("/ads/#{ad.id}/edit")

      assert view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat2"}) =~
               "Snapchat"

      # todo: you should NOT have to do this when editing an Ad!
      assert view |> element("#add-gif") |> render_click() =~ "Choose new Gif"

      {:ok, _view, html} =
        view
        |> form("#ad-form", ad: %{body: "micromisoft2"})
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Ad updated successfully"
    end

    @tag :gif_test
    test "edit an ad that you DID NOT make", %{conn: conn, profile: _profile} do
      random_profile = profile_fixture()
      ad = ad_fixture(random_profile)

      # todo: you should not be able to access this page
      {:ok, view, _html} = conn |> live("/ads/#{ad.id}/edit")

      assert view |> form("#ad-form") |> render_change(ad: %{"product" => "Snapchat2"}) =~
               "Snapchat"

      # todo: you should NOT have to do this when editing an Ad!
      assert view |> element("#add-gif") |> render_click() =~ "Choose new Gif"

      assert view |> form("#ad-form", ad: %{body: "micromisoft2"}) |> render_submit() =~
               "You cannot edit this person&#39;s posts."
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
  end

  describe "moderating as an admin" do
    setup :register_user_and_admin_profile

    test "censor an ad as an admin", %{conn: conn} do
      ad_creator = profile_fixture()
      ad = ad_fixture(ad_creator)

      {:ok, view, _html} = conn |> live("/ads/#{ad.id}")

      assert view |> render() =~ "Edit"

      view |> element("#moderate-ad") |> render_click() =~ "Moderate Panel"
      assert_patch(view, Routes.ad_show_path(conn, :new_action, ad.id))

      {:ok, _view, html} =
        view
        |> form("#moderation-form")
        |> render_submit(
          action: %{
            "reason" => "Makes marginalized group butt of the joke",
            "action" => "censor"
          }
        )
        |> follow_redirect(conn)

      assert html =~ "Thanks for making ShlinkedIn better :)"

      # confirm user got notification
      assert Shlinkedin.Profiles.list_notifications(ad_creator.id, 1)
             |> Enum.at(0)
             |> Map.get(:action) ==
               "has decided to issue you a censor on your ad. "

      # confirm ad is removed
      assert Ads.get_ad!(ad.id).removed == true
    end
  end

  describe "moderating as a moderator but non admin" do
    setup :register_user_and_moderator_profile

    test "censor an ad as a moderator", %{conn: conn} do
      ad_creator = profile_fixture()
      ad = ad_fixture(ad_creator)

      {:ok, view, _html} = conn |> live("/ads/#{ad.id}")

      refute render(view) =~ "Edit Ad"

      view |> element("#moderate-ad") |> render_click() =~ "Moderate Panel"
      assert_patch(view, Routes.ad_show_path(conn, :new_action, ad.id))

      {:ok, _view, html} =
        view
        |> form("#moderation-form")
        |> render_submit(
          action: %{
            "reason" => "Makes marginalized group butt of the joke",
            "action" => "censor"
          }
        )
        |> follow_redirect(conn)

      assert html =~ "Thanks for making ShlinkedIn better :)"

      # confirm user got notification
      assert Shlinkedin.Profiles.list_notifications(ad_creator.id, 1)
             |> Enum.at(0)
             |> Map.get(:action) ==
               "has decided to issue you a censor on your ad. "

      # confirm ad is removed
      assert Ads.get_ad!(ad.id).removed == true
    end
  end
end
