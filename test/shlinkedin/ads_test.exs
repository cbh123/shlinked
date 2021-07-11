defmodule Shlinkedin.ProfilesTest do
  use Shlinkedin.DataCase
  import Shlinkedin.ProfilesFixtures
  import Shlinkedin.PointsFixtures
  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad

  describe "ads" do
    @valid_ad %{
      body: "micromisoft",
      company: "facebook",
      product: "computer",
      quantity: 5,
      price: "1",
      gif_url: "test"
    }
    @update_attrs %{
      body: "update body",
      quantity: 7,
      product: "new product",
      gif_url: "test2"
    }
    @invalid_attrs %{body: nil, quantity: -1}

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
      assert ad.quantity == 5
      assert ad.gif_url == "test"
    end

    test "update_ad/2 with valid data updates the endorsement", %{profile: profile} do
      ad = ad_fixture(profile)

      assert {:ok, %Ad{} = ad} = Ads.update_ad(profile, ad, @update_attrs)

      assert ad.body == "update body"
      assert ad.quantity == 7
      assert ad.product == "new product"
      assert ad.gif_url == "test2"
    end

    test "update_ad/2 with invalid data fails", %{profile: profile} do
      ad = ad_fixture(profile)

      assert {:error, %Ecto.Changeset{}} = Ads.update_ad(profile, ad, @invalid_attrs)
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
      assert Ads.get_ad_owner_profile_id(ad) == profile.id
      {:error, _message} = Ads.check_ownership(ad, profile)

      # second txn
      new_profile = profile_fixture()
      {:ok, _owner} = Ads.create_owner(ad, transaction, new_profile)
      assert Ads.get_ad_owner_profile_id(ad) == new_profile.id
      {:error, _profile} = Ads.check_ownership(ad, new_profile)
      {:ok, _profile} = Ads.check_ownership(ad, profile)
    end

    test "test valid_quantity/1", %{ad: ad, profile: profile} do
      assert Ads.check_quantity(ad) == {:ok, ad}

      {:ok, new_ad} = Ads.update_ad(profile, ad, %{quantity: 0})
      {:error, _message} = Ads.check_quantity(new_ad)
    end

    test "test enough_points", %{ad: ad, profile: profile} do
      assert Ads.check_money(ad, profile) == {:ok, ad}
      {:ok, new_ad} = Ads.update_ad(profile, ad, %{price: "100"})
      {:error, _message} = Ads.check_money(new_ad, profile)
    end

    test "test buy_ad", %{ad: ad, profile: profile} do
      Ads.buy_ad(ad, profile)
    end

    test "test buying ad with not enough money", %{ad: ad, profile: profile} do
      {:ok, new_ad} = Ads.update_ad(profile, ad, %{price: "100"})
      {:error, "You are too poor"} = Ads.buy_ad(new_ad, profile)
    end

    test "test buy sold out ad", %{ad: ad, profile: profile} do
      {:ok, new_ad} = Ads.update_ad(profile, ad, %{quantity: 0})
      {:error, "Sold out"} = Ads.buy_ad(new_ad, profile)
    end

    test "test buy ad that you already own", %{ad: ad, profile: profile, transaction: transaction} do
      {:ok, _owner} = Ads.create_owner(ad, transaction, profile)

      {:error, "You cannot own more than 1 of an ad, you greedy capitalist!"} =
        Ads.buy_ad(ad, profile)
    end
  end
end
