defmodule ShlinkedinWeb.ProfileLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.ProfilesFixtures
  alias Shlinkedin.Profiles

  setup do
    %{to_profile: profile_fixture()}
  end

  describe "View profile as signed in user" do
    setup :register_user_and_profile

    test "profile view has to be unique per day", %{
      conn: conn,
      profile: _profile,
      to_profile: to_profile
    } do
      {:ok, _view, _html} = live(conn, Routes.profile_show_path(conn, :show, to_profile.slug))

      to_profile = Profiles.get_profile_by_profile_id(to_profile.id)

      assert to_profile.points.amount ==
               100 + Shlinkedin.Points.get_rule_amount(:profile_view).amount

      {:ok, _view, _html} = live(conn, Routes.profile_show_path(conn, :show, to_profile.slug))
      {:ok, _view, _html} = live(conn, Routes.profile_show_path(conn, :show, to_profile.slug))
      {:ok, _view, _html} = live(conn, Routes.profile_show_path(conn, :show, to_profile.slug))
      to_profile = Profiles.get_profile_by_profile_id(to_profile.id)

      assert to_profile.points.amount ==
               100 + Shlinkedin.Points.get_rule_amount(:profile_view).amount
    end

    test "write a testimonial", %{conn: conn, profile: _profile, to_profile: to_profile} do
      {:ok, view, _html} = live(conn, Routes.profile_show_path(conn, :show, to_profile.slug))

      assert view
             |> element("#review", "+ Review")
             |> render_click() =~
               "Write a review for #{to_profile.persona_name}"

      assert_patch(view, Routes.profile_show_path(conn, :new_testimonial, to_profile.slug))

      assert view
             |> form("#testimonial-form",
               testimonial: %{relation: "You and Mr. studied together", body: "", rating: 5}
             )
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        view
        |> form("#testimonial-form",
          testimonial: %{relation: "You and Mr. studied together", body: "Great work", rating: 5}
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.profile_show_path(conn, :show, to_profile.slug))

      assert html =~ "Review created!"
      assert html =~ "Great work"

      # check adds points to to_profile
      to_profile = Profiles.get_profile_by_profile_id(to_profile.id)

      assert to_profile.points.amount ==
               100 + Shlinkedin.Points.get_rule_amount(:testimonial).amount +
                 Shlinkedin.Points.get_rule_amount(:profile_view).amount
    end
  end
end
