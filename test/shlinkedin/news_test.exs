defmodule Shlinkedin.NewsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.News

  describe "headline ordering" do
    @criteria [paginate: %{page: 1, per_page: 5}]

    setup do
      profile = Shlinkedin.ProfilesFixtures.profile_fixture()
      create_headlines(10, profile)
      %{profile: profile}
    end

    defp create_headlines(num, profile) do
      Enum.each(
        1..num,
        fn num ->
          {:ok, _article} =
            News.create_article(profile, %News.Article{}, %{headline: Integer.to_string(num)})
        end
      )
    end

    test "check headline ordering first page" do
      headlines =
        News.list_articles(@criteria, %{type: "new", time: "all_time"})
        |> Enum.map(fn a -> String.to_integer(a.headline) end)

      assert headlines == [10, 9, 8, 7, 6]
    end

    test "check headline ordering second page" do
      headlines =
        News.list_articles([paginate: %{page: 2, per_page: 5}], %{type: "new", time: "all_time"})
        |> Enum.map(fn a -> String.to_integer(a.headline) end)

      assert headlines == [5, 4, 3, 2, 1]
    end
  end

  describe "content" do
    alias Shlinkedin.News.Content

    import Shlinkedin.NewsFixtures

    @invalid_attrs %{author: nil, content: nil}

    test "list_content/0 returns all content" do
      content = content_fixture()
      assert News.list_content() == [content]
    end

    test "get_content!/1 returns the content with given id" do
      content = content_fixture()
      assert News.get_content!(content.id) == content
    end

    test "create_content/1 with valid data creates a content" do
      valid_attrs = %{author: "some author", content: "some content"}

      assert {:ok, %Content{} = content} = News.create_content(valid_attrs)
      assert content.author == "some author"
      assert content.content == "some content"
    end

    test "create_content/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = News.create_content(@invalid_attrs)
    end

    test "update_content/2 with valid data updates the content" do
      content = content_fixture()
      update_attrs = %{author: "some updated author", content: "some updated content"}

      assert {:ok, %Content{} = content} = News.update_content(content, update_attrs)
      assert content.author == "some updated author"
      assert content.content == "some updated content"
    end

    test "update_content/2 with invalid data returns error changeset" do
      content = content_fixture()
      assert {:error, %Ecto.Changeset{}} = News.update_content(content, @invalid_attrs)
      assert content == News.get_content!(content.id)
    end

    test "delete_content/1 deletes the content" do
      content = content_fixture()
      assert {:ok, %Content{}} = News.delete_content(content)
      assert_raise Ecto.NoResultsError, fn -> News.get_content!(content.id) end
    end

    test "change_content/1 returns a content changeset" do
      content = content_fixture()
      assert %Ecto.Changeset{} = News.change_content(content)
    end
  end
end
