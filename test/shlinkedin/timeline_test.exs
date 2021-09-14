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

  describe "post order" do
    @criteria [paginate: %{page: 1, per_page: 6}]

    setup do
      profile = Shlinkedin.ProfilesFixtures.profile_fixture()
      create_posts(profile)
      %{profile: profile}
    end

    defp create_posts(profile) do
      {:ok, _post} = Timeline.create_post(profile, %{body: "first"}, %Timeline.Post{})
      _post = create_post(3) |> add_likes()
      _post = create_post(5) |> add_likes()
      _post = create_post(1) |> add_likes()

      {:ok, _featured_post} =
        Timeline.create_post(
          profile,
          %{body: "featured", featured: true, featured_date: NaiveDateTime.utc_now()},
          %Timeline.Post{}
        )

      {:ok, _pinned} =
        Timeline.create_post(profile, %{body: "pinned", pinned: true}, %Timeline.Post{})
    end

    defp create_post(num_likes) do
      {:ok, post} =
        Timeline.create_post(
          Shlinkedin.ProfilesFixtures.profile_fixture(),
          %{body: post_body(num_likes)},
          %Timeline.Post{}
        )

      {num_likes, post}
    end

    defp add_likes({num_likes, post}) do
      Enum.each(
        1..num_likes,
        fn _num ->
          Timeline.create_like(Shlinkedin.ProfilesFixtures.profile_fixture(), post, "nice")
        end
      )

      post
    end

    defp post_body(1), do: "1_like"
    defp post_body(num), do: "#{num}_likes"

    test "new posts", %{profile: profile} do
      posts =
        Timeline.list_posts(profile, @criteria, %{
          type: "new",
          time: "today"
        })
        |> Enum.map(fn p -> p.body end)

      assert posts == ["pinned", "featured", "1_like", "5_likes", "3_likes", "first"]
    end

    test "featured posts", %{profile: profile} do
      posts =
        Timeline.list_posts(profile, @criteria, %{
          type: "featured",
          time: "today"
        })
        |> Enum.map(fn p -> p.body end)

      assert posts == ["featured"]
    end

    test "profile posts", %{profile: profile} do
      posts =
        Timeline.list_posts(profile, @criteria, %{
          type: "profile",
          time: "today"
        })
        |> Enum.map(fn p -> p.body end)

      assert posts == ["pinned", "featured", "first"]

      random_profile = Shlinkedin.ProfilesFixtures.profile_fixture()

      assert Timeline.list_posts(random_profile, @criteria, %{type: "profile", time: "today"}) ==
               []
    end

    test "reactions post", %{profile: profile} do
      posts =
        Timeline.list_posts(profile, @criteria, %{
          type: "reactions",
          time: "today"
        })
        |> Enum.map(fn p -> p.body end)

      assert posts == ["pinned", "5_likes", "3_likes", "1_like", "featured", "first"]
    end

    test "reactions post with 3 per page", %{profile: profile} do
      posts =
        Timeline.list_posts(profile, [paginate: %{page: 1, per_page: 3}], %{
          type: "reactions",
          time: "today"
        })
        |> Enum.map(fn p -> p.body end)

      assert posts == ["pinned", "5_likes", "3_likes"]
    end
  end

  describe "edit posts" do
    setup do
      profile = Shlinkedin.ProfilesFixtures.profile_fixture()
      %{profile: profile}
    end

    test "edit post that isn't yours", %{profile: profile} do
      {:ok, post} = Timeline.create_post(profile, %{body: "first"}, %Timeline.Post{})
      new_profile = Shlinkedin.ProfilesFixtures.profile_fixture()

      {:error, %Ecto.Changeset{}} = Timeline.update_post(new_profile, post, %{body: "update"})
    end

    test "edit post that isn't yours but you're an admin", %{profile: profile} do
      admin = Shlinkedin.ProfilesFixtures.profile_fixture(%{"admin" => true})

      {:ok, post} = Timeline.create_post(profile, %{body: "first"}, %Timeline.Post{})

      {:ok, post} = Timeline.update_post(admin, post, %{body: "update"})

      assert post.body == "update"
    end
  end
end
