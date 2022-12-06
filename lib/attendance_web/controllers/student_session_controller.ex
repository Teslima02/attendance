defmodule AttendanceWeb.StudentSessionController do
  use AttendanceWeb, :controller

  alias Attendance.Students
  alias AttendanceWeb.StudentAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"student" => student_params}) do
    %{"email" => email, "password" => password} = student_params

    if student = Students.get_student_by_email_and_password(email, password) do
      StudentAuth.log_in_student(conn, student, student_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> StudentAuth.log_out_student()
  end
end
