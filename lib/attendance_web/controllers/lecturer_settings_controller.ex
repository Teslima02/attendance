defmodule AttendanceWeb.LecturerSettingsController do
  use AttendanceWeb, :controller

  alias Attendance.Lecturers
  alias AttendanceWeb.LecturerAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "lecturer" => lecturer_params} = params
    lecturer = conn.assigns.current_lecturer

    case Lecturers.apply_lecturer_email(lecturer, password, lecturer_params) do
      {:ok, applied_lecturer} ->
        Lecturers.deliver_update_email_instructions(
          applied_lecturer,
          lecturer.email,
          &Routes.lecturer_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.lecturer_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "lecturer" => lecturer_params} = params
    lecturer = conn.assigns.current_lecturer

    case Lecturers.update_lecturer_password(lecturer, password, lecturer_params) do
      {:ok, lecturer} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:lecturer_return_to, Routes.lecturer_settings_path(conn, :edit))
        |> LecturerAuth.log_in_lecturer(lecturer)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Lecturers.update_lecturer_email(conn.assigns.current_lecturer, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.lecturer_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.lecturer_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    lecturer = conn.assigns.current_lecturer

    conn
    |> assign(:email_changeset, Lecturers.change_lecturer_email(lecturer))
    |> assign(:password_changeset, Lecturers.change_lecturer_password(lecturer))
  end
end
