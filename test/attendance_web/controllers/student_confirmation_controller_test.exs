defmodule AttendanceWeb.StudentConfirmationControllerTest do
  use AttendanceWeb.ConnCase, async: true

  alias Attendance.Students
  alias Attendance.Repo
  import Attendance.StudentsFixtures

  setup do
    %{student: student_fixture()}
  end

  describe "GET /students/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.student_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /students/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, student: student} do
      conn =
        post(conn, Routes.student_confirmation_path(conn, :create), %{
          "student" => %{"email" => student.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Students.StudentToken, student_id: student.id).context == "confirm"
    end

    test "does not send confirmation token if Student is confirmed", %{conn: conn, student: student} do
      Repo.update!(Students.Student.confirm_changeset(student))

      conn =
        post(conn, Routes.student_confirmation_path(conn, :create), %{
          "student" => %{"email" => student.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Students.StudentToken, student_id: student.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.student_confirmation_path(conn, :create), %{
          "student" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Students.StudentToken) == []
    end
  end

  describe "GET /students/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.student_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.student_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /students/confirm/:token" do
    test "confirms the given token once", %{conn: conn, student: student} do
      token =
        extract_student_token(fn url ->
          Students.deliver_student_confirmation_instructions(student, url)
        end)

      conn = post(conn, Routes.student_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Student confirmed successfully"
      assert Students.get_student!(student.id).confirmed_at
      refute get_session(conn, :student_token)
      assert Repo.all(Students.StudentToken) == []

      # When not logged in
      conn = post(conn, Routes.student_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Student confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_student(student)
        |> post(Routes.student_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, student: student} do
      conn = post(conn, Routes.student_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Student confirmation link is invalid or it has expired"
      refute Students.get_student!(student.id).confirmed_at
    end
  end
end
