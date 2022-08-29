defmodule Shlinkedin.PointsTest do
  use Shlinkedin.DataCase
  alias Shlinkedin.Points

  setup do
    profile = Shlinkedin.ProfilesFixtures.profile_fixture()
    _profile2 = Shlinkedin.ProfilesFixtures.profile_fixture()
    %{profile: profile}
  end

  test "total profile points?", %{} do
    %Money{amount: 200} = Points.get_total_points()
  end

  test "add statistic", %{} do
    total_points = Points.get_total_points()

    {:ok, stat} =
      Points.create_statistic(%{
        total_points: total_points
      })

    assert stat.total_points.amount == 200
  end
end
