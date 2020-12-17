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

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    # view and show posts
    live "/", PostLive.Index, :index
    live "/posts/new", PostLive.Index, :new
    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/edit", PostLive.Index, :edit
    live "/posts/:id/new_comment", PostLive.Index, :new_comment
    live "/posts/:id/show/edit", PostLive.Show, :edit
    live "/posts/:id/likes", PostLive.Index, :show_likes

    ### profile
    live "/sh/:slug", ProfileLive.Show, :show
    live "/sh/:slug/endorsements/new", ProfileLive.Show, :new_endorsement
    live "/sh/:slug/endorsement/:id/edit", ProfileLive.Show, :edit_endorsement
    live "/sh/:slug/testimonials/new", ProfileLive.Show, :new_testimonial
    live "/sh/:slug/testimonial/:id/edit", ProfileLive.Show, :edit_testimonial

    live "/profile/live_edit", ProfileLive.Edit, :edit
    live "/profile/welcome", ProfileLive.Edit, :new

    live "/shlinks", FriendLive.Index, :index
    live "/updates",
  end

  scope "/", ShlinkedinWeb do
    pipe_through [:browser]

    get "/join", UserRegistrationController, :join

    # auth stuff
    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
