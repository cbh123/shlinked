defmodule Shlinkedin.PointsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Points` context.
  """
  import Shlinkedin.ProfilesFixtures
  alias Shlinkedin.Points

  def transaction_fixture(attrs \\ %{}) do
    p1 = profile_fixture()
    p2 = profile_fixture()

    {:ok, transaction} =
      Points.create_transaction(
        p1,
        p2,
        attrs
        |> Enum.into(%{
          "amount" => 1,
          "note" => "nothing"
        })
      )

    transaction
  end
end
