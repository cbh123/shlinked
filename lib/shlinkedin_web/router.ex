defmodule ShlinkedinWeb.Router do
  use ShlinkedinWeb, :router

  import ShlinkedinWeb.UserAuth

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
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ShlinkedinWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", ShlinkedinWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
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
    live "/posts/:id/comments", PostLive.Index, :show_comments
    live "/posts/:id/show/edit", PostLive.Show, :edit

    # profile
    get "/profile/new", ProfileController, :new
    post "/profile/new", ProfileController, :create
    get "/profile/settings", ProfileController, :edit
    post "/profile/settings", ProfileController, :update
  end

  scope "/", ShlinkedinWeb do
    pipe_through [:browser]

    # auth stuff
    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
