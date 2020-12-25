defmodule Shlinkedin.NewsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.News

  describe "articles" do
    alias Shlinkedin.News.Article

    @valid_attrs %{headline: "some headline", media_url: "some media_url", slug: "some slug"}
    @update_attrs %{headline: "some updated headline", media_url: "some updated media_url", slug: "some updated slug"}
    @invalid_attrs %{headline: nil, media_url: nil, slug: nil}

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> News.create_article()

      article
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert News.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert News.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = News.create_article(@valid_attrs)
      assert article.headline == "some headline"
      assert article.media_url == "some media_url"
      assert article.slug == "some slug"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = News.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, %Article{} = article} = News.update_article(article, @update_attrs)
      assert article.headline == "some updated headline"
      assert article.media_url == "some updated media_url"
      assert article.slug == "some updated slug"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = News.update_article(article, @invalid_attrs)
      assert article == News.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = News.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> News.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = News.change_article(article)
    end
  end
end
