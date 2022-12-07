defmodule AttendanceWeb.StudentResetPasswordController do
  use AttendanceWeb, :controller

  alias Attendance.Students

  plug :get_student_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"student" => %{"email" => email}}) do
    if student = Students.get_student_by_email(email) do
      Students.deliver_student_reset_password_instructions(
        student,
        &Routes.student_reset_password_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Students.change_student_password(conn.assigns.student))
  end

  # Do not log in the student after reset password to avoid a
  # leaked token giving the student access to the account.
  def update(conn, %{"student" => student_params}) do
    case Students.reset_student_password(conn.assigns.student, student_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.student_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_student_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if student = Students.get_student_by_reset_password_token(token) do
      conn |> assign(:student, student) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
