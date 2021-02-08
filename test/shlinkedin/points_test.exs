defmodule Shlinkedin.PointsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Points

  describe "transactions" do
    alias Shlinkedin.Points.Transaction

    @valid_attrs %{amount: 42, notes: "some notes"}
    @update_attrs %{amount: 43, notes: "some updated notes"}
    @invalid_attrs %{amount: nil, notes: nil}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Points.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Points.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Points.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = Points.create_transaction(@valid_attrs)
      assert transaction.amount == 42
      assert transaction.notes == "some notes"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Points.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{} = transaction} = Points.update_transaction(transaction, @update_attrs)
      assert transaction.amount == 43
      assert transaction.notes == "some updated notes"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Points.update_transaction(transaction, @invalid_attrs)
      assert transaction == Points.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Points.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Points.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Points.change_transaction(transaction)
    end
  end
end
