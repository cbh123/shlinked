defmodule Shlinkedin.InternsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Interns

  describe "interns" do
    alias Shlinkedin.Interns.Intern

    import Shlinkedin.InternsFixtures

    @invalid_attrs %{age: nil, last_fed: nil, name: nil}

    test "list_interns/0 returns all interns" do
      intern = intern_fixture()
      assert Interns.list_interns() == [intern]
    end

    test "get_intern!/1 returns the intern with given id" do
      intern = intern_fixture()
      assert Interns.get_intern!(intern.id) == intern
    end

    test "create_intern/1 with valid data creates a intern" do
      valid_attrs = %{age: 42, last_fed: ~N[2022-08-27 21:40:00], name: "some name"}

      assert {:ok, %Intern{} = intern} = Interns.create_intern(valid_attrs)
      assert intern.age == 42
      assert intern.last_fed == ~N[2022-08-27 21:40:00]
      assert intern.name == "some name"
    end

    test "create_intern/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Interns.create_intern(@invalid_attrs)
    end

    test "update_intern/2 with valid data updates the intern" do
      intern = intern_fixture()
      update_attrs = %{age: 43, last_fed: ~N[2022-08-28 21:40:00], name: "some updated name"}

      assert {:ok, %Intern{} = intern} = Interns.update_intern(intern, update_attrs)
      assert intern.age == 43
      assert intern.last_fed == ~N[2022-08-28 21:40:00]
      assert intern.name == "some updated name"
    end

    test "update_intern/2 with invalid data returns error changeset" do
      intern = intern_fixture()
      assert {:error, %Ecto.Changeset{}} = Interns.update_intern(intern, @invalid_attrs)
      assert intern == Interns.get_intern!(intern.id)
    end

    test "delete_intern/1 deletes the intern" do
      intern = intern_fixture()
      assert {:ok, %Intern{}} = Interns.delete_intern(intern)
      assert_raise Ecto.NoResultsError, fn -> Interns.get_intern!(intern.id) end
    end

    test "change_intern/1 returns a intern changeset" do
      intern = intern_fixture()
      assert %Ecto.Changeset{} = Interns.change_intern(intern)
    end
  end
end
