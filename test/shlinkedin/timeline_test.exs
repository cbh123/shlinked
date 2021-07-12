defmodule Shlinkedin.TimelineTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Timeline

  describe "taglines" do
    alias Shlinkedin.Timeline.Tagline

    @valid_attrs %{active: true, text: "some text"}
    @update_attrs %{active: false, text: "some updated text"}
    @invalid_attrs %{active: nil, text: nil}

    def tagline_fixture(attrs \\ %{}) do
      {:ok, tagline} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_tagline()

      tagline
    end

    test "list_taglines/0 returns all taglines" do
      tagline = tagline_fixture()
      assert Timeline.list_taglines() == [tagline]
    end

    test "get_tagline!/1 returns the tagline with given id" do
      tagline = tagline_fixture()
      assert Timeline.get_tagline!(tagline.id) == tagline
    end

    test "create_tagline/1 with valid data creates a tagline" do
      assert {:ok, %Tagline{} = tagline} = Timeline.create_tagline(@valid_attrs)
      assert tagline.active == true
      assert tagline.text == "some text"
    end

    test "create_tagline/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_tagline(@invalid_attrs)
    end

    test "update_tagline/2 with valid data updates the tagline" do
      tagline = tagline_fixture()
      assert {:ok, %Tagline{} = tagline} = Timeline.update_tagline(tagline, @update_attrs)
      assert tagline.active == false
      assert tagline.text == "some updated text"
    end

    test "update_tagline/2 with invalid data returns error changeset" do
      tagline = tagline_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_tagline(tagline, @invalid_attrs)
      assert tagline == Timeline.get_tagline!(tagline.id)
    end

    test "delete_tagline/1 deletes the tagline" do
      tagline = tagline_fixture()
      assert {:ok, %Tagline{}} = Timeline.delete_tagline(tagline)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_tagline!(tagline.id) end
    end

    test "change_tagline/1 returns a tagline changeset" do
      tagline = tagline_fixture()
      assert %Ecto.Changeset{} = Timeline.change_tagline(tagline)
    end
  end
end
