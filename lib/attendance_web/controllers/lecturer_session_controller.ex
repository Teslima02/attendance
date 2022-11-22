defmodule AttendanceWeb.LecturerSessionController do
  use AttendanceWeb, :controller

  alias Attendance.Lecturers
  alias AttendanceWeb.LecturerAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"lecturer" => lecturer_params}) do
    %{"email" => email, "password" => password} = lecturer_params

    if lecturer = Lecturers.get_lecturer_by_email_and_password(email, password) do
      LecturerAuth.log_in_lecturer(conn, lecturer, lecturer_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> LecturerAuth.log_out_lecturer()
  end
end
