defmodule AttendanceWeb.StudentSettingsController do
  use AttendanceWeb, :controller

  alias Attendance.Students
  alias AttendanceWeb.StudentAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "student" => student_params} = params
    student = conn.assigns.current_student

    case Students.apply_student_email(student, password, student_params) do
      {:ok, applied_student} ->
        Students.deliver_update_email_instructions(
          applied_student,
          student.email,
          &Routes.student_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.student_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "student" => student_params} = params
    student = conn.assigns.current_student

    case Students.update_student_password(student, password, student_params) do
      {:ok, student} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:student_return_to, Routes.student_settings_path(conn, :edit))
        |> StudentAuth.log_in_student(student)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Students.update_student_email(conn.assigns.current_student, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.student_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.student_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    student = conn.assigns.current_student

    conn
    |> assign(:email_changeset, Students.change_student_email(student))
    |> assign(:password_changeset, Students.change_student_password(student))
  end
end
