# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Shlinkedin.Repo.insert!(%Shlinkedin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Shlinkedin.Timeline

# create user / profile
{:ok, user} = Shlinkedin.Accounts.register_user(%{email: "god@shlinkedin.com", password: "bloop"})

{:ok, profile} =
  Shlinkedin.Profiles.create_profile(user, %{
    "persona_name" => "god",
    "slug" => "god",
    "title" => "god",
    "username" => "god"
  })

# create a post
{:ok, _post} = Timeline.create_post(profile, %{body: "first"}, %Timeline.Post{})

# helper for adding likes
defp add_likes(profile, num_likes) do
  Enum.each(
    1..num_likes,
    fn _num ->
      Timeline.create_like(Shlinkedin.ProfilesFixtures.profile_fixture(), post, "nice")
    end
  )

  post
end

_post = add_likes(profile, 3)
