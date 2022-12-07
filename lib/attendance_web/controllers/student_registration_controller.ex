defmodule AttendanceWeb.StudentRegistrationController do
  use AttendanceWeb, :controller

  alias Attendance.Students
  alias Attendance.Students.Student
  alias AttendanceWeb.StudentAuth

  def new(conn, _params) do
    changeset = Students.change_student_registration(%Student{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"student" => student_params}) do
    case Students.register_student(student_params) do
      {:ok, student} ->
        {:ok, _} =
          Students.deliver_student_confirmation_instructions(
            student,
            &Routes.student_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Student created successfully.")
        |> StudentAuth.log_in_student(student)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
