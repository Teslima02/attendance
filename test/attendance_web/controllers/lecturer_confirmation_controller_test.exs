defmodule AttendanceWeb.LecturerConfirmationControllerTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Lecturers
  alias Attendance.Repo
  import Attendance.LecturersFixtures

  setup do
    %{lecturer: lecturer_fixture()}
  end

  describe "GET /lecturers/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.lecturer_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /lecturers/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, lecturer: lecturer} do
      conn =
        post(conn, Routes.lecturer_confirmation_path(conn, :create), %{
          "lecturer" => %{"email" => lecturer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Lecturers.LecturerToken, lecturer_id: lecturer.id).context == "confirm"
    end

    test "does not send confirmation token if Lecturer is confirmed", %{conn: conn, lecturer: lecturer} do
      Repo.update!(Lecturers.Lecturer.confirm_changeset(lecturer))

      conn =
        post(conn, Routes.lecturer_confirmation_path(conn, :create), %{
          "lecturer" => %{"email" => lecturer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Lecturers.LecturerToken, lecturer_id: lecturer.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.lecturer_confirmation_path(conn, :create), %{
          "lecturer" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Lecturers.LecturerToken) == []
    end
  end

  describe "GET /lecturers/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.lecturer_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.lecturer_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /lecturers/confirm/:token" do
    test "confirms the given token once", %{conn: conn, lecturer: lecturer} do
      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_lecturer_confirmation_instructions(lecturer, url)
        end)

      conn = post(conn, Routes.lecturer_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Lecturer confirmed successfully"
      assert Lecturers.get_lecturer!(lecturer.id).confirmed_at
      refute get_session(conn, :lecturer_token)
      assert Repo.all(Lecturers.LecturerToken) == []

      # When not logged in
      conn = post(conn, Routes.lecturer_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Lecturer confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_lecturer(lecturer)
        |> post(Routes.lecturer_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, lecturer: lecturer} do
      conn = post(conn, Routes.lecturer_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Lecturer confirmation link is invalid or it has expired"
      refute Lecturers.get_lecturer!(lecturer.id).confirmed_at
    end
  end
end
