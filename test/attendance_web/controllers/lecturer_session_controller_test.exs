defmodule AttendanceWeb.LecturerSessionControllerTest do
  use AttendanceWeb.ConnCase, async: true

  import Attendance.LecturersFixtures

  setup do
    %{lecturer: lecturer_fixture()}
  end

  describe "GET /lecturers/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.lecturer_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, lecturer: lecturer} do
      conn = conn |> log_in_lecturer(lecturer) |> get(Routes.lecturer_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /lecturers/log_in" do
    test "logs the lecturer in", %{conn: conn, lecturer: lecturer} do
      conn =
        post(conn, Routes.lecturer_session_path(conn, :create), %{
          "lecturer" => %{"email" => lecturer.email, "password" => valid_lecturer_password()}
        })

      assert get_session(conn, :lecturer_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ lecturer.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the lecturer in with remember me", %{conn: conn, lecturer: lecturer} do
      conn =
        post(conn, Routes.lecturer_session_path(conn, :create), %{
          "lecturer" => %{
            "email" => lecturer.email,
            "password" => valid_lecturer_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_attendance_web_lecturer_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the lecturer in with return to", %{conn: conn, lecturer: lecturer} do
      conn =
        conn
        |> init_test_session(lecturer_return_to: "/foo/bar")
        |> post(Routes.lecturer_session_path(conn, :create), %{
          "lecturer" => %{
            "email" => lecturer.email,
            "password" => valid_lecturer_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, lecturer: lecturer} do
      conn =
        post(conn, Routes.lecturer_session_path(conn, :create), %{
          "lecturer" => %{"email" => lecturer.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /lecturers/log_out" do
    test "logs the lecturer out", %{conn: conn, lecturer: lecturer} do
      conn = conn |> log_in_lecturer(lecturer) |> delete(Routes.lecturer_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :lecturer_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the lecturer is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.lecturer_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :lecturer_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
