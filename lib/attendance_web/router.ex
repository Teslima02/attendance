defmodule AttendanceWeb.Router do
  use AttendanceWeb, :router

  import AttendanceWeb.StudentAuth

  import AttendanceWeb.LecturerAuth

  import AttendanceWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AttendanceWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_student
    plug :fetch_current_lecturer
    plug :fetch_current_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug AttendanceWeb.Plug.StudentContext
    plug AttendanceWeb.Plug.LecturerContext
    # plug Corsica, origins: "*", allow_headers: :all
  end

  scope "/graphql" do
    pipe_through :graphql
    forward "/", Absinthe.Plug.GraphiQL, schema: AttendanceApi.Schema, socket: AttendanceWeb.UserSocket
  end

  # scope "/api" do
  #   pipe_through :graphql

  #   forward "/", Absinthe.Plug, schema: AttendanceApi.Schema
  # end

  # if Mix.env == :dev do
  #   forward "/graphiql", Absinthe.Plug.GraphiQL, schema: AttendanceApi.Schema
  # end

  scope "/", AttendanceWeb do
    pipe_through [:browser]

    get "/login", AdminSessionController, :new
    live "/guess", WrongView
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser, :require_authenticated_admin]

    get "/", PageController, :index

    live "/sessions", SessionLive.Index, :index
    live "/sessions/new", SessionLive.Index, :new
    live "/sessions/:id/edit", SessionLive.Index, :edit

    live "/sessions/:id", SessionLive.Show, :show
    live "/sessions/:id/show/edit", SessionLive.Show, :edit

    live "/sessions/:session_id/show/program/new", SessionLive.Show, :new_program
    live "/sessions/:session_id/show/program/edit", SessionLive.Show, :edit_program

    live "/sessions/:session_id/show/program/:program_id", SessionLive.ShowProgram, :show_program
    live "/sessions/:session_id/show/program/edit/:program_id", SessionLive.ShowProgram, :edit_program

    live "/sessions/:session_id/program/:program_id/class/new", SessionLive.ShowProgram, :new_class
    live "/sessions/:session_id/program/:program_id/class/edit", SessionLive.ShowProgram, :edit_class

    live "/sessions/:session_id/program/:program_id/class/show/:class_id", SessionLive.ShowClass, :show_class
    live "/sessions/:session_id/program/:program_id/class/edit/:class_id", SessionLive.ShowClass, :edit_class

    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/new", SessionLive.ShowClass, :new_semester

    live "/sessions/:session_id/program/:program_id/class/:class_id/student/upload", SessionLive.ShowClass, :upload_student

    live "/sessions/:session_id/program/:program_id/class/:class_id/student/show/:student_id", SessionLive.ShowStudent, :show_student
    live "/sessions/:session_id/program/:program_id/class/:class_id/student/edit/:student_id", SessionLive.ShowStudent, :edit_student

    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/show/:semester_id", SessionLive.ShowSemester, :show_semester
    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/edit/:semester_id", SessionLive.ShowSemester, :edit_semester

    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/:semester_id/upload/course", SessionLive.ShowSemester, :upload_course
    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/:semester_id/course/:course_id/edit", SessionLive.ShowSemester, :edit_course
    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/:semester_id/course/:course_id/assign", SessionLive.ShowSemester, :assign_course

    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/:semester_id/create/timetable", SessionLive.ShowSemester, :create_timetable
    live "/sessions/:session_id/program/:program_id/class/:class_id/semester/:semester_id/timetable/:timetable_id/edit", SessionLive.ShowSemester, :edit_timetable
    # live "/sessions/:session_id/program/:program_id/class/:class_id/semester/:semester_id/timetable/:timetable_id/show", SessionLive.ShowSemester, :show_timetable

    live "/lecturers", LecturerLive.Index, :index
    live "/lecturers/new", LecturerLive.Index, :upload_lecturer
    live "/lecturers/:id/edit", LecturerLive.Index, :edit

    live "/lecturers/:id", LecturerLive.Show, :show
    live "/lecturers/:id/show/edit", LecturerLive.Show, :edit

    live "/students", StudentLive.Index, :index
    live "/students/new", StudentLive.Index, :new
    live "/students/:id/edit", StudentLive.Index, :edit

    live "/students/:id", StudentLive.Show, :show
    live "/students/:id/show/edit", StudentLive.Show, :edit

    live "/lecturer_halls", Lecturer_hallLive.Index, :index
    live "/lecturer_halls/new", Lecturer_hallLive.Index, :new
    live "/lecturer_halls/:id/edit", Lecturer_hallLive.Index, :edit

    live "/lecturer_halls/:id", Lecturer_hallLive.Show, :show
    live "/lecturer_halls/:id/show/edit", Lecturer_hallLive.Show, :edit

    live "/timetables", TimetableLive.Index, :index
    live "/timetables/new", TimetableLive.Index, :new
    live "/timetables/:id/edit", TimetableLive.Index, :edit

    live "/timetables/:id", TimetableLive.Show, :show
    live "/timetables/:id/show/edit", TimetableLive.Show, :edit
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

  ## Authentication routes

  scope "/", AttendanceWeb do
    pipe_through [:browser, :redirect_if_lecturer_is_authenticated]

    get "/lecturers/register", LecturerRegistrationController, :new
    post "/lecturers/register", LecturerRegistrationController, :create
    get "/lecturers/log_in", LecturerSessionController, :new
    post "/lecturers/log_in", LecturerSessionController, :create
    get "/lecturers/reset_password", LecturerResetPasswordController, :new
    post "/lecturers/reset_password", LecturerResetPasswordController, :create
    get "/lecturers/reset_password/:token", LecturerResetPasswordController, :edit
    put "/lecturers/reset_password/:token", LecturerResetPasswordController, :update
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser, :require_authenticated_lecturer]

    get "/lecturers/settings", LecturerSettingsController, :edit
    put "/lecturers/settings", LecturerSettingsController, :update
    get "/lecturers/settings/confirm_email/:token", LecturerSettingsController, :confirm_email
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser]

    delete "/lecturers/log_out", LecturerSessionController, :delete
    get "/lecturers/confirm", LecturerConfirmationController, :new
    post "/lecturers/confirm", LecturerConfirmationController, :create
    get "/lecturers/confirm/:token", LecturerConfirmationController, :edit
    post "/lecturers/confirm/:token", LecturerConfirmationController, :update
  end

  ## Authentication routes

  scope "/", AttendanceWeb do
    pipe_through [:browser, :redirect_if_student_is_authenticated]

    get "/students/register", StudentRegistrationController, :new
    post "/students/register", StudentRegistrationController, :create
    get "/students/log_in", StudentSessionController, :new
    post "/students/log_in", StudentSessionController, :create
    get "/students/reset_password", StudentResetPasswordController, :new
    post "/students/reset_password", StudentResetPasswordController, :create
    get "/students/reset_password/:token", StudentResetPasswordController, :edit
    put "/students/reset_password/:token", StudentResetPasswordController, :update
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser, :require_authenticated_student]

    get "/students/settings", StudentSettingsController, :edit
    put "/students/settings", StudentSettingsController, :update
    get "/students/settings/confirm_email/:token", StudentSettingsController, :confirm_email
  end

  scope "/", AttendanceWeb do
    pipe_through [:browser]

    delete "/students/log_out", StudentSessionController, :delete
    get "/students/confirm", StudentConfirmationController, :new
    post "/students/confirm", StudentConfirmationController, :create
    get "/students/confirm/:token", StudentConfirmationController, :edit
    post "/students/confirm/:token", StudentConfirmationController, :update
  end
end
