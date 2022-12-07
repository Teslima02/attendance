defmodule AttendanceWeb.StudentSettingsControllerTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Students
  import Attendance.StudentsFixtures

  setup :register_and_log_in_student

  describe "GET /students/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.student_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if student is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.student_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.student_session_path(conn, :new)
    end
  end

  describe "PUT /students/settings (change password form)" do
    test "updates the student password and resets tokens", %{conn: conn, student: student} do
      new_password_conn =
        put(conn, Routes.student_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_student_password(),
          "student" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.student_settings_path(conn, :edit)
      assert get_session(new_password_conn, :student_token) != get_session(conn, :student_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Students.get_student_by_email_and_password(student.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.student_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "student" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :student_token) == get_session(conn, :student_token)
    end
  end

  describe "PUT /students/settings (change email form)" do
    @tag :capture_log
    test "updates the student email", %{conn: conn, student: student} do
      conn =
        put(conn, Routes.student_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_student_password(),
          "student" => %{"email" => unique_student_email()}
        })

      assert redirected_to(conn) == Routes.student_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Students.get_student_by_email(student.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.student_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "student" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /students/settings/confirm_email/:token" do
    setup %{student: student} do
      email = unique_student_email()

      token =
        extract_student_token(fn url ->
          Students.deliver_update_email_instructions(%{student | email: email}, student.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the student email once", %{conn: conn, student: student, token: token, email: email} do
      conn = get(conn, Routes.student_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.student_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Students.get_student_by_email(student.email)
      assert Students.get_student_by_email(email)

      conn = get(conn, Routes.student_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.student_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, student: student} do
      conn = get(conn, Routes.student_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.student_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Students.get_student_by_email(student.email)
    end

    test "redirects if student is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.student_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.student_session_path(conn, :new)
    end
  end
end
