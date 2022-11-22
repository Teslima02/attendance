defmodule AttendanceWeb.LecturerResetPasswordControllerTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Lecturers
  alias Attendance.Repo
  import Attendance.LecturersFixtures

  setup do
    %{lecturer: lecturer_fixture()}
  end

  describe "GET /lecturers/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.lecturer_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /lecturers/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, lecturer: lecturer} do
      conn =
        post(conn, Routes.lecturer_reset_password_path(conn, :create), %{
          "lecturer" => %{"email" => lecturer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Lecturers.LecturerToken, lecturer_id: lecturer.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.lecturer_reset_password_path(conn, :create), %{
          "lecturer" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Lecturers.LecturerToken) == []
    end
  end

  describe "GET /lecturers/reset_password/:token" do
    setup %{lecturer: lecturer} do
      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_lecturer_reset_password_instructions(lecturer, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.lecturer_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.lecturer_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /lecturers/reset_password/:token" do
    setup %{lecturer: lecturer} do
      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_lecturer_reset_password_instructions(lecturer, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, lecturer: lecturer, token: token} do
      conn =
        put(conn, Routes.lecturer_reset_password_path(conn, :update, token), %{
          "lecturer" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.lecturer_session_path(conn, :new)
      refute get_session(conn, :lecturer_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Lecturers.get_lecturer_by_email_and_password(lecturer.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.lecturer_reset_password_path(conn, :update, token), %{
          "lecturer" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.lecturer_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
