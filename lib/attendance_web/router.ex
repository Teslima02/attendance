defmodule AttendanceWeb.Router do
  use AttendanceWeb, :router

  import AttendanceWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AttendanceWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser]

    get "/", PageController, :index
    live "/guess", WrongView
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser, :require_authenticated_admin]

    live "/programs", ProgramLive.Index, :index
    live "/programs/new", ProgramLive.Index, :new
    live "/programs/:id/edit", ProgramLive.Index, :edit

    live "/programs/:id", ProgramLive.Show, :show
    live "/programs/:id/show/edit", ProgramLive.Show, :edit

    live "/sessions", SessionLive.Index, :index
    live "/sessions/new", SessionLive.Index, :new
    live "/sessions/:id/edit", SessionLive.Index, :edit

    live "/sessions/:id", SessionLive.Show, :show
    live "/sessions/:id/show/edit", SessionLive.Show, :edit

    live "/sessions/:id/show/program", SessionLive.ShowProgram, :show_program
    live "/sessions/:id/show/program/edit", SessionLive.ShowProgram, :edit_program

    live "/sessions/:id/show/program/new", SessionLive.Show, :new_program
    live "/sessions/:id/show/program/edit", SessionLive.Show, :edit_program

    live "/sessions/:session_id/program/class/new", SessionLive.ShowProgram, :new_class
    live "/sessions/:session_id/program/class/edit", SessionLive.ShowProgram, :edit_class

    live "/sessions/:session_id/show/semester/new", SessionLive.Show, :new_semester
    live "/sessions/:session_id/show/semester/edit", SessionLive.Show, :edit_semester

    live "/semesters", SemesterLive.Index, :index
    live "/semesters/new", SemesterLive.Index, :new
    live "/semesters/:id/edit", SemesterLive.Index, :edit

    live "/semesters/:id", SemesterLive.Show, :show
    live "/semesters/:id/show/edit", SemesterLive.Show, :edit

    live "/classes", ClassLive.Index, :index
    live "/classes/new", ClassLive.Index, :new
    live "/classes/:id/edit", ClassLive.Index, :edit

    live "/classes/:id", ClassLive.Show, :show
    live "/classes/:id/show/edit", ClassLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", AttendanceWeb do
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

      live_dashboard "/dashboard", metrics: AttendanceWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AttendanceWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    get "/admins/register", AdminRegistrationController, :new
    post "/admins/register", AdminRegistrationController, :create
    get "/admins/log_in", AdminSessionController, :new
    post "/admins/log_in", AdminSessionController, :create
    get "/admins/reset_password", AdminResetPasswordController, :new
    post "/admins/reset_password", AdminResetPasswordController, :create
    get "/admins/reset_password/:token", AdminResetPasswordController, :edit
    put "/admins/reset_password/:token", AdminResetPasswordController, :update
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser, :require_authenticated_admin]

    get "/admins/settings", AdminSettingsController, :edit
    put "/admins/settings", AdminSettingsController, :update
    get "/admins/settings/confirm_email/:token", AdminSettingsController, :confirm_email
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser]

    delete "/admins/log_out", AdminSessionController, :delete
    get "/admins/confirm", AdminConfirmationController, :new
    post "/admins/confirm", AdminConfirmationController, :create
    get "/admins/confirm/:token", AdminConfirmationController, :edit
    post "/admins/confirm/:token", AdminConfirmationController, :update
  end
end
