defmodule AttendanceWeb.StudentResetPasswordControllerTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Students
  alias Attendance.Repo
  import Attendance.StudentsFixtures

  setup do
    %{student: student_fixture()}
  end

  describe "GET /students/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.student_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /students/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, student: student} do
      conn =
        post(conn, Routes.student_reset_password_path(conn, :create), %{
          "student" => %{"email" => student.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Students.StudentToken, student_id: student.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.student_reset_password_path(conn, :create), %{
          "student" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Students.StudentToken) == []
    end
  end

  describe "GET /students/reset_password/:token" do
    setup %{student: student} do
      token =
        extract_student_token(fn url ->
          Students.deliver_student_reset_password_instructions(student, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.student_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.student_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /students/reset_password/:token" do
    setup %{student: student} do
      token =
        extract_student_token(fn url ->
          Students.deliver_student_reset_password_instructions(student, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, student: student, token: token} do
      conn =
        put(conn, Routes.student_reset_password_path(conn, :update, token), %{
          "student" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.student_session_path(conn, :new)
      refute get_session(conn, :student_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Students.get_student_by_email_and_password(student.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.student_reset_password_path(conn, :update, token), %{
          "student" => %{
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
      conn = put(conn, Routes.student_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
