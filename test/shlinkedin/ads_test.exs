defmodule Shlinkedin.AdsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Ads

  describe "ads" do
    alias Shlinkedin.Ads.Ad

    @valid_attrs %{body: "some body", media_url: "some media_url", slug: "some slug"}
    @update_attrs %{body: "some updated body", media_url: "some updated media_url", slug: "some updated slug"}
    @invalid_attrs %{body: nil, media_url: nil, slug: nil}

    def ad_fixture(attrs \\ %{}) do
      {:ok, ad} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ads.create_ad()

      ad
    end

    test "list_ads/0 returns all ads" do
      ad = ad_fixture()
      assert Ads.list_ads() == [ad]
    end

    test "get_ad!/1 returns the ad with given id" do
      ad = ad_fixture()
      assert Ads.get_ad!(ad.id) == ad
    end

    test "create_ad/1 with valid data creates a ad" do
      assert {:ok, %Ad{} = ad} = Ads.create_ad(@valid_attrs)
      assert ad.body == "some body"
      assert ad.media_url == "some media_url"
      assert ad.slug == "some slug"
    end

    test "create_ad/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ads.create_ad(@invalid_attrs)
    end

    test "update_ad/2 with valid data updates the ad" do
      ad = ad_fixture()
      assert {:ok, %Ad{} = ad} = Ads.update_ad(ad, @update_attrs)
      assert ad.body == "some updated body"
      assert ad.media_url == "some updated media_url"
      assert ad.slug == "some updated slug"
    end

    test "update_ad/2 with invalid data returns error changeset" do
      ad = ad_fixture()
      assert {:error, %Ecto.Changeset{}} = Ads.update_ad(ad, @invalid_attrs)
      assert ad == Ads.get_ad!(ad.id)
    end

    test "delete_ad/1 deletes the ad" do
      ad = ad_fixture()
      assert {:ok, %Ad{}} = Ads.delete_ad(ad)
      assert_raise Ecto.NoResultsError, fn -> Ads.get_ad!(ad.id) end
    end

    test "change_ad/1 returns a ad changeset" do
      ad = ad_fixture()
      assert %Ecto.Changeset{} = Ads.change_ad(ad)
    end
  end
end
