defmodule ShlinkedinWeb.Router do
  use ShlinkedinWeb, :router

  import ShlinkedinWeb.UserAuth
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ShlinkedinWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admins_only do
    plug :basic_auth,
      username: System.get_env("ADMIN_USER"),
      password: System.get_env("ADMIN_PASSWORD")
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShlinkedinWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).

  scope "/" do
    pipe_through [:browser, :admins_only]
    live_dashboard "/dashboard", metrics: ShlinkedinWeb.Telemetry, ecto_repos: [Shlinkedin.Repo]
  end

  ## Authentication routes

  scope "/", ShlinkedinWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/register", UserRegistrationController, :new

    post "/register", UserRegistrationController, :create
    get "/log_in", UserSessionController, :new
    post "/log_in", UserSessionController, :create
    get "/reset_password", UserResetPasswordController, :new
    post "/reset_password", UserResetPasswordController, :create
    get "/reset_password/:token", UserResetPasswordController, :edit
    put "/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", ShlinkedinWeb do
    pipe_through [:browser, :require_authenticated_user]

    # user settings
    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    # view and show posts
    live "/", HomeLive.Index, :index
    live "/home", HomeLive.Index, :index
    live "/home/posts/new", HomeLive.Index, :new
    live "/home/posts/:id", HomeLive.Show, :show
    live "/home/posts/:id/edit", HomeLive.Index, :edit
    live "/home/posts/:id/new_comment", HomeLive.Index, :new_comment
    live "/home/posts/:id/new_comment?reply_to=:username", HomeLive.Index, :new_comment
    live "/home/posts/:id/show/edit", HomeLive.Show, :edit
    live "/home/posts/:id/likes", HomeLive.Index, :show_likes
    live "/home/posts/:comment_id/comment_likes", HomeLive.Index, :show_comment_likes
    live "/home/posts/:id/:notifications", HomeLive.Show, :show

    # stories
    live "/stories/new", HomeLive.Index, :new_story
    live "/stories/:profile_id/:story_id", StoryLive.Show, :show
    live "/stories/:profile_id", StoryLive.Show, :show

    ### profile
    live "/sh/:slug", ProfileLive.Show, :show
    live "/sh/:slug/endorsements/new", ProfileLive.Show, :new_endorsement
    live "/sh/:slug/endorsement/:id/edit", ProfileLive.Show, :edit_endorsement
    live "/sh/:slug/testimonials/new", ProfileLive.Show, :new_testimonial
    live "/sh/:slug/testimonial/:id/edit", ProfileLive.Show, :edit_testimonial
    live "/sh/:slug/notifications", ProfileLive.Show, :from_notifications
    live "/sh/:slug/awards/", ProfileLive.Show, :edit_awards
    live "/sh/:slug/posts/:post_id/likes", ProfileLive.Show, :show_likes
    live "/sh/:slug/posts/:post_id/new_comment", ProfileLive.Show, :new_comment
    live "/sh/:slug/posts/:post_id/new_comment?reply_to=:username", ProfileLive.Show, :new_comment
    live "/sh/:slug/posts/:comment_id/comment_likes", ProfileLive.Show, :show_comment_likes

    # edit profile
    live "/profile/live_edit", ProfileLive.Edit, :edit
    live "/profile/welcome", ProfileLive.Edit, :new

    # friends
    live "/shlinks", FriendLive.Index, :index
    live "/shlinks/:notifications", FriendLive.Index, :index

    # notifications
    live "/updates", NotificationLive.Index, :index

    # menu
    live "/menu", MenuLive.Index, :index

    # admin
    live "/admin", AdminLive.Index, :index
    live "/admin/notification/new", AdminLive.Index, :new_notification
    live "/admin/email/new", AdminLive.Index, :new_email
    live "/award_types", AwardTypeLive.Index, :index
    live "/award_types/new", AwardTypeLive.Index, :new
    live "/award_types/:id/edit", AwardTypeLive.Index, :edit

    live "/award_types/:id", AwardTypeLive.Show, :show
    live "/award_types/:id/show/edit", AwardTypeLive.Show, :edit

    # show all profiles
    live "/profiles", UsersLive.Index, :index

    # news
    live "/news", ArticleLive.Index, :index
    live "/new_article", HomeLive.Index, :new_article
    live "/news/:id/votes/", HomeLive.Index, :show_votes
    live "/news/:id/show_votes/", ArticleLive.Index, :show_votes
    live "/news/new", ArticleLive.Index, :new_article
    live "/news/:id", ArticleLive.Show, :show

    # ads
    live "/ads/new", HomeLive.Index, :new_ad
    live "/ads/:id/edit", HomeLive.Index, :edit_ad
    live "/ads/:id", AdLive.Show, :show

    # groups
    live "/groups", GroupLive.Index, :index
    live "/groups/new", GroupLive.Index, :new
    live "/groups/:id", GroupLive.Show, :show
    live "/groups/:id/show/edit", GroupLive.Show, :edit_group
    live "/groups/:id/new_post", GroupLive.Show, :new
    live "/groups/:id/posts/:post_id/likes", GroupLive.Show, :show_likes
    live "/groups/:id/posts/:post_id/new_comment", GroupLive.Show, :new_comment
    live "/groups/:id/posts/:post_id/new_comment?reply_to=:username", GroupLive.Show, :new_comment
    live "/groups/:id/posts/:comment_id/comment_likes", GroupLive.Show, :show_comment_likes

    # search
    # live "/search", SearchLive.Index, :index
    # live "/search/:query", SearchLive.Index, :index
  end

  scope "/", ShlinkedinWeb do
    pipe_through [:browser]

    # onboarding
    live "/onboarding/:id", OnboardingLive.Index, :index

    get "/join", UserRegistrationController, :join

    # auth stuff
    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
