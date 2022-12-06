defmodule AttendanceWeb.StudentSessionControllerTest do
  use AttendanceWeb.ConnCase, async: true

  import Attendance.StudentsFixtures

  setup do
    %{student: student_fixture()}
  end

  describe "GET /students/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.student_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, student: student} do
      conn = conn |> log_in_student(student) |> get(Routes.student_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /students/log_in" do
    test "logs the student in", %{conn: conn, student: student} do
      conn =
        post(conn, Routes.student_session_path(conn, :create), %{
          "student" => %{"email" => student.email, "password" => valid_student_password()}
        })

      assert get_session(conn, :student_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ student.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the student in with remember me", %{conn: conn, student: student} do
      conn =
        post(conn, Routes.student_session_path(conn, :create), %{
          "student" => %{
            "email" => student.email,
            "password" => valid_student_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_attendance_web_student_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the student in with return to", %{conn: conn, student: student} do
      conn =
        conn
        |> init_test_session(student_return_to: "/foo/bar")
        |> post(Routes.student_session_path(conn, :create), %{
          "student" => %{
            "email" => student.email,
            "password" => valid_student_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, student: student} do
      conn =
        post(conn, Routes.student_session_path(conn, :create), %{
          "student" => %{"email" => student.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /students/log_out" do
    test "logs the student out", %{conn: conn, student: student} do
      conn = conn |> log_in_student(student) |> delete(Routes.student_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :student_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the student is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.student_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :student_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
