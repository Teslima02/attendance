defmodule AttendanceWeb.LecturerAuthTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Lecturers
  alias AttendanceWeb.LecturerAuth
  import Attendance.LecturersFixtures

  @remember_me_cookie "_attendance_web_lecturer_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AttendanceWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{lecturer: lecturer_fixture(), conn: conn}
  end

  describe "log_in_lecturer/3" do
    test "stores the lecturer token in the session", %{conn: conn, lecturer: lecturer} do
      conn = LecturerAuth.log_in_lecturer(conn, lecturer)
      assert token = get_session(conn, :lecturer_token)
      assert get_session(conn, :live_socket_id) == "lecturers_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Lecturers.get_lecturer_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, lecturer: lecturer} do
      conn = conn |> put_session(:to_be_removed, "value") |> LecturerAuth.log_in_lecturer(lecturer)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, lecturer: lecturer} do
      conn = conn |> put_session(:lecturer_return_to, "/hello") |> LecturerAuth.log_in_lecturer(lecturer)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, lecturer: lecturer} do
      conn = conn |> fetch_cookies() |> LecturerAuth.log_in_lecturer(lecturer, %{"remember_me" => "true"})
      assert get_session(conn, :lecturer_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :lecturer_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_lecturer/1" do
    test "erases session and cookies", %{conn: conn, lecturer: lecturer} do
      lecturer_token = Lecturers.generate_lecturer_session_token(lecturer)

      conn =
        conn
        |> put_session(:lecturer_token, lecturer_token)
        |> put_req_cookie(@remember_me_cookie, lecturer_token)
        |> fetch_cookies()
        |> LecturerAuth.log_out_lecturer()

      refute get_session(conn, :lecturer_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Lecturers.get_lecturer_by_session_token(lecturer_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "lecturers_sessions:abcdef-token"
      AttendanceWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> LecturerAuth.log_out_lecturer()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if lecturer is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> LecturerAuth.log_out_lecturer()
      refute get_session(conn, :lecturer_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_lecturer/2" do
    test "authenticates lecturer from session", %{conn: conn, lecturer: lecturer} do
      lecturer_token = Lecturers.generate_lecturer_session_token(lecturer)
      conn = conn |> put_session(:lecturer_token, lecturer_token) |> LecturerAuth.fetch_current_lecturer([])
      assert conn.assigns.current_lecturer.id == lecturer.id
    end

    test "authenticates lecturer from cookies", %{conn: conn, lecturer: lecturer} do
      logged_in_conn =
        conn |> fetch_cookies() |> LecturerAuth.log_in_lecturer(lecturer, %{"remember_me" => "true"})

      lecturer_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> LecturerAuth.fetch_current_lecturer([])

      assert get_session(conn, :lecturer_token) == lecturer_token
      assert conn.assigns.current_lecturer.id == lecturer.id
    end

    test "does not authenticate if data is missing", %{conn: conn, lecturer: lecturer} do
      _ = Lecturers.generate_lecturer_session_token(lecturer)
      conn = LecturerAuth.fetch_current_lecturer(conn, [])
      refute get_session(conn, :lecturer_token)
      refute conn.assigns.current_lecturer
    end
  end

  describe "redirect_if_lecturer_is_authenticated/2" do
    test "redirects if lecturer is authenticated", %{conn: conn, lecturer: lecturer} do
      conn = conn |> assign(:current_lecturer, lecturer) |> LecturerAuth.redirect_if_lecturer_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if lecturer is not authenticated", %{conn: conn} do
      conn = LecturerAuth.redirect_if_lecturer_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_lecturer/2" do
    test "redirects if lecturer is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> LecturerAuth.require_authenticated_lecturer([])
      assert conn.halted
      assert redirected_to(conn) == Routes.lecturer_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> LecturerAuth.require_authenticated_lecturer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :lecturer_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> LecturerAuth.require_authenticated_lecturer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :lecturer_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> LecturerAuth.require_authenticated_lecturer([])

      assert halted_conn.halted
      refute get_session(halted_conn, :lecturer_return_to)
    end

    test "does not redirect if lecturer is authenticated", %{conn: conn, lecturer: lecturer} do
      conn = conn |> assign(:current_lecturer, lecturer) |> LecturerAuth.require_authenticated_lecturer([])
      refute conn.halted
      refute conn.status
    end
  end
end
