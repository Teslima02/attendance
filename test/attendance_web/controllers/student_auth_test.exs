defmodule AttendanceWeb.StudentAuthTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Students
  alias AttendanceWeb.StudentAuth
  import Attendance.StudentsFixtures

  @remember_me_cookie "_attendance_web_student_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AttendanceWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{student: student_fixture(), conn: conn}
  end

  describe "log_in_student/3" do
    test "stores the student token in the session", %{conn: conn, student: student} do
      conn = StudentAuth.log_in_student(conn, student)
      assert token = get_session(conn, :student_token)
      assert get_session(conn, :live_socket_id) == "students_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Students.get_student_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, student: student} do
      conn = conn |> put_session(:to_be_removed, "value") |> StudentAuth.log_in_student(student)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, student: student} do
      conn = conn |> put_session(:student_return_to, "/hello") |> StudentAuth.log_in_student(student)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, student: student} do
      conn = conn |> fetch_cookies() |> StudentAuth.log_in_student(student, %{"remember_me" => "true"})
      assert get_session(conn, :student_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :student_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_student/1" do
    test "erases session and cookies", %{conn: conn, student: student} do
      student_token = Students.generate_student_session_token(student)

      conn =
        conn
        |> put_session(:student_token, student_token)
        |> put_req_cookie(@remember_me_cookie, student_token)
        |> fetch_cookies()
        |> StudentAuth.log_out_student()

      refute get_session(conn, :student_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Students.get_student_by_session_token(student_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "students_sessions:abcdef-token"
      AttendanceWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> StudentAuth.log_out_student()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if student is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> StudentAuth.log_out_student()
      refute get_session(conn, :student_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_student/2" do
    test "authenticates student from session", %{conn: conn, student: student} do
      student_token = Students.generate_student_session_token(student)
      conn = conn |> put_session(:student_token, student_token) |> StudentAuth.fetch_current_student([])
      assert conn.assigns.current_student.id == student.id
    end

    test "authenticates student from cookies", %{conn: conn, student: student} do
      logged_in_conn =
        conn |> fetch_cookies() |> StudentAuth.log_in_student(student, %{"remember_me" => "true"})

      student_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> StudentAuth.fetch_current_student([])

      assert get_session(conn, :student_token) == student_token
      assert conn.assigns.current_student.id == student.id
    end

    test "does not authenticate if data is missing", %{conn: conn, student: student} do
      _ = Students.generate_student_session_token(student)
      conn = StudentAuth.fetch_current_student(conn, [])
      refute get_session(conn, :student_token)
      refute conn.assigns.current_student
    end
  end

  describe "redirect_if_student_is_authenticated/2" do
    test "redirects if student is authenticated", %{conn: conn, student: student} do
      conn = conn |> assign(:current_student, student) |> StudentAuth.redirect_if_student_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if student is not authenticated", %{conn: conn} do
      conn = StudentAuth.redirect_if_student_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_student/2" do
    test "redirects if student is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> StudentAuth.require_authenticated_student([])
      assert conn.halted
      assert redirected_to(conn) == Routes.student_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> StudentAuth.require_authenticated_student([])

      assert halted_conn.halted
      assert get_session(halted_conn, :student_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> StudentAuth.require_authenticated_student([])

      assert halted_conn.halted
      assert get_session(halted_conn, :student_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> StudentAuth.require_authenticated_student([])

      assert halted_conn.halted
      refute get_session(halted_conn, :student_return_to)
    end

    test "does not redirect if student is authenticated", %{conn: conn, student: student} do
      conn = conn |> assign(:current_student, student) |> StudentAuth.require_authenticated_student([])
      refute conn.halted
      refute conn.status
    end
  end
end
