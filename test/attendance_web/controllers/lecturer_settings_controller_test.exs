defmodule AttendanceWeb.LecturerSettingsControllerTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Lecturers
  import Attendance.LecturersFixtures

  setup :register_and_log_in_lecturer

  describe "GET /lecturers/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.lecturer_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if lecturer is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.lecturer_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.lecturer_session_path(conn, :new)
    end
  end

  describe "PUT /lecturers/settings (change password form)" do
    test "updates the lecturer password and resets tokens", %{conn: conn, lecturer: lecturer} do
      new_password_conn =
        put(conn, Routes.lecturer_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_lecturer_password(),
          "lecturer" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.lecturer_settings_path(conn, :edit)
      assert get_session(new_password_conn, :lecturer_token) != get_session(conn, :lecturer_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Lecturers.get_lecturer_by_email_and_password(lecturer.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.lecturer_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "lecturer" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :lecturer_token) == get_session(conn, :lecturer_token)
    end
  end

  describe "PUT /lecturers/settings (change email form)" do
    @tag :capture_log
    test "updates the lecturer email", %{conn: conn, lecturer: lecturer} do
      conn =
        put(conn, Routes.lecturer_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_lecturer_password(),
          "lecturer" => %{"email" => unique_lecturer_email()}
        })

      assert redirected_to(conn) == Routes.lecturer_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Lecturers.get_lecturer_by_email(lecturer.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.lecturer_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "lecturer" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /lecturers/settings/confirm_email/:token" do
    setup %{lecturer: lecturer} do
      email = unique_lecturer_email()

      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_update_email_instructions(%{lecturer | email: email}, lecturer.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the lecturer email once", %{conn: conn, lecturer: lecturer, token: token, email: email} do
      conn = get(conn, Routes.lecturer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.lecturer_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Lecturers.get_lecturer_by_email(lecturer.email)
      assert Lecturers.get_lecturer_by_email(email)

      conn = get(conn, Routes.lecturer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.lecturer_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, lecturer: lecturer} do
      conn = get(conn, Routes.lecturer_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.lecturer_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Lecturers.get_lecturer_by_email(lecturer.email)
    end

    test "redirects if lecturer is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.lecturer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.lecturer_session_path(conn, :new)
    end
  end
end
