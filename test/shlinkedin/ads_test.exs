defmodule Shlinkedin.AdsTest do
  use Shlinkedin.DataCase
  import Shlinkedin.ProfilesFixtures
  import Shlinkedin.PointsFixtures
  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Profiles

  describe "ads" do
    @valid_ad %{
      body: "micromisoft",
      company: "facebook",
      product: "computer",
      price: "1",
      gif_url: "test"
    }
    @update_attrs %{
      body: "update body",
      product: "new product",
      gif_url: "test2"
    }
    @invalid_attrs %{body: nil}

    def ad_fixture(profile, attrs \\ %{}) do
      {:ok, ad} = Ads.create_ad(profile, %Ad{}, attrs |> Enum.into(@valid_ad))

      ad
    end

    setup do
      profile = profile_fixture()
      ad = ad_fixture(profile)
      transaction = transaction_fixture()
      %{profile: profile, ad: ad, transaction: transaction}
    end

    test "create_ad creates an ad", %{profile: profile} do
      assert {:ok, %Ad{} = ad} = Ads.create_ad(profile, %Ad{}, @valid_ad)

      assert ad.company == "facebook"
      assert ad.gif_url == "test"
    end

    test "create_ad success subtracts SPs", %{} do
      rich_profile = profile_fixture(%{"points" => "1000"})
      assert rich_profile.points.amount == 100_000

      assert {:ok, %Ad{} = ad} =
               Ads.create_ad(rich_profile, %Ad{}, %{
                 body: "micromisoft",
                 company: "facebook",
                 product: "computer",
                 price: "500",
                 gif_url: "test"
               })

      profile = Profiles.get_profile_by_profile_id(rich_profile.id)
      assert ad.price == Money.new(50000, :SHLINK)
      assert profile.points.amount == 87500
      assert ad.company == "facebook"
      assert ad.gif_url == "test"
    end

    test "create_ad error does not subtracts SPs", %{} do
      expensive_ad_attrs = Enum.into(%{price: "50000"}, @valid_ad)

      poor_profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Ads.create_ad(poor_profile, %Ad{}, expensive_ad_attrs)

      rich_profile = profile_fixture(%{"points" => "1000000"})
      assert {:ok, _ad} = Ads.create_ad(rich_profile, %Ad{}, expensive_ad_attrs)
    end

    test "update_ad/2 with valid data updates the endorsement", %{profile: profile} do
      ad = ad_fixture(profile)

      assert {:ok, %Ad{} = ad} = Ads.update_ad(ad, @update_attrs)

      assert ad.body == "update body"
      assert ad.product == "new product"
      assert ad.gif_url == "test2"
    end

    test "update_ad/2 with invalid data fails", %{profile: profile} do
      ad = ad_fixture(profile)

      assert {:error, %Ecto.Changeset{}} = Ads.update_ad(ad, @invalid_attrs)
    end

    test "create_owner adds a new row to the ad owner table", %{profile: profile, ad: ad} do
      transaction = transaction_fixture()
      {:ok, owner} = Ads.create_owner(ad, transaction, profile)
      assert owner.ad_id == ad.id
      assert owner.profile_id == profile.id
      assert owner.transaction_id == transaction.id
    end

    test "get_ad_owner gets latest owner", %{profile: profile, ad: ad, transaction: transaction} do
      # first txn
      {:ok, _owner} = Ads.create_owner(ad, transaction, profile)
      assert Ads.get_ad_owner(ad).id == profile.id
      ad = Ads.get_ad!(ad.id)
      assert ad.owner_id == nil

      # second txn
      new_profile = profile_fixture()
      {:ok, _owner} = Ads.create_owner(ad, transaction, new_profile)
      assert Ads.get_ad_owner(ad).id == new_profile.id

      assert ad.owner_id == nil
    end

    test "test enough_points", %{ad: ad, profile: profile} do
      assert Ads.check_money(ad, profile) == {:ok, ad}
      {:ok, new_ad} = Ads.update_ad(ad, %{price: "100"})
      {:error, _message} = Ads.check_money(new_ad, profile)
    end

    test "test buy_ad success", %{} do
      buyer = profile_fixture()
      creator = profile_fixture()
      ad = ad_fixture(creator)
      # presets
      assert Shlinkedin.Points.list_transactions(buyer) |> length() == 0
      assert Ads.get_ad_owner(ad).id != buyer.id

      # buy ad
      {:ok, ad} = Ads.buy_ad(ad, buyer)

      # changes
      new_buyer = Profiles.get_profile_by_profile_id(buyer.id)
      assert Shlinkedin.Points.list_transactions(new_buyer) |> length() == 1
      assert Ads.get_ad_owner(ad).id == new_buyer.id
      assert new_buyer.points.amount == buyer.points.amount - ad.price.amount
      [last_notification] = Profiles.list_notifications(creator.id, 1)
      assert last_notification.to_profile_id == creator.id
      assert last_notification.from_profile_id == new_buyer.id

      assert last_notification.action ==
               "#{new_buyer.persona_name} bought your ad for '#{ad.product}' for #{ad.price}"
    end

    test "test buying ad with not enough money", %{ad: ad, profile: profile} do
      {:ok, new_ad} = Ads.update_ad(ad, %{price: "100"})
      {:error, "You are too poor"} = Ads.buy_ad(new_ad, profile)
    end

    test "test buy ad that you already own", %{ad: ad, profile: profile, transaction: transaction} do
      {:ok, _owner} = Ads.create_owner(ad, transaction, profile)

      {:error, _changeset} = Ads.buy_ad(ad, profile)
    end

    test "test buy_ad a second time success", %{} do
      profile = profile_fixture()
      other_profile = profile_fixture()
      ad = ad_fixture(other_profile)

      # presets
      assert Shlinkedin.Points.list_transactions(profile) |> length() == 0
      assert Ads.get_ad_owner(ad).id != profile.id

      # buy ad
      {:ok, ad} = Ads.buy_ad(ad, profile)
      other_profile = Shlinkedin.Profiles.get_profile_by_profile_id(other_profile.id)
      assert other_profile.points.amount == 175
      assert ad.owner_id == profile.id

      # og profile buys it back
      {:ok, ad} = Ads.buy_ad(ad, other_profile)
      new_other_profile = Shlinkedin.Profiles.get_profile_by_profile_id(other_profile.id)
      assert Shlinkedin.Points.list_transactions(other_profile) |> length() == 3
      assert Ads.get_ad_owner(ad).id == new_other_profile.id
      assert ad.owner_id == new_other_profile.id
      assert new_other_profile.points.amount == other_profile.points.amount - ad.price.amount

      [last_notification] = Profiles.list_notifications(profile.id, 1)
      assert last_notification.to_profile_id == profile.id
      assert last_notification.from_profile_id == new_other_profile.id

      assert last_notification.action ==
               "#{new_other_profile.persona_name} bought your ad for '#{ad.product}' for #{ad.price}"
    end

    test "test last buy", %{} do
      random_profile = profile_fixture()
      rich_profile = profile_fixture(%{"points" => "100000"})
      ad = ad_fixture(random_profile)

      # buy ad
      {:ok, _ad} = Ads.buy_ad(ad, rich_profile)

      {:ok, _} = Ads.check_time(random_profile)
      {:error, _} = Ads.check_time(rich_profile)
    end

    test "test create ad with negative doesn't give you points", %{} do
      profile = profile_fixture()
      assert profile.points.amount == 100
      attrs = Enum.into(%{price: "-50"}, @valid_ad)

      {:error, _ad} = Ads.create_ad(profile, %Ad{}, attrs)

      profile = Profiles.get_profile_by_profile_id(profile.id)
      assert profile.points.amount == 90
    end

    test "number of ads created", %{profile: profile} do
      assert Ads.get_number_ads_created(profile) == 1
      ad_fixture(profile)
      assert Ads.get_number_ads_created(profile) == 2
    end

    test "no more than 3 ads per hour", %{} do
      rich_profile = profile_fixture(%{"points" => "1000"})
      {:ok, _ad} = Ads.create_ad(rich_profile, %Ad{}, @valid_ad)
      {:ok, _ad} = Ads.create_ad(rich_profile, %Ad{}, @valid_ad)
      {:ok, _ad} = Ads.create_ad(rich_profile, %Ad{}, @valid_ad)
      {:error, _ad} = Ads.create_ad(rich_profile, %Ad{}, @valid_ad)
    end
  end
end
