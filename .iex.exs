import Ecto.Query, warn: false
alias Shlinkedin.Repo
alias Shlinkedin.Profiles
alias Shlinkedin.Awards.AwardType

alias Shlinkedin.Profiles.{
  Endorsement,
  Award,
  Jab,
  Testimonial,
  ProfileNotifier,
  Profile,
  Notification,
  Friend,
  Invite,
  ProfileView
}

alias Shlinkedin.Accounts.User
alias Shlinkedin.Points
alias Shlinkedin.News
alias Shlinkedin.News.{Article, Vote}
