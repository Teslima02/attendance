defmodule AttendanceWeb.StudentLiveTest do
  use AttendanceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Attendance.StudentsFixtures

  @create_attrs %{disabled: true, first_name: "some first_name", last_name: "some last_name", matric_number: "some matric_number", middle_name: "some middle_name"}
  @update_attrs %{disabled: false, first_name: "some updated first_name", last_name: "some updated last_name", matric_number: "some updated matric_number", middle_name: "some updated middle_name"}
  @invalid_attrs %{disabled: false, first_name: nil, last_name: nil, matric_number: nil, middle_name: nil}

  defp create_student(_) do
    student = student_fixture()
    %{student: student}
  end

  describe "Index" do
    setup [:create_student]

    test "lists all students", %{conn: conn, student: student} do
      {:ok, _index_live, html} = live(conn, Routes.student_index_path(conn, :index))

      assert html =~ "Listing Students"
      assert html =~ student.first_name
    end

    test "saves new student", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.student_index_path(conn, :index))

      assert index_live |> element("a", "New Student") |> render_click() =~
               "New Student"

      assert_patch(index_live, Routes.student_index_path(conn, :new))

      assert index_live
             |> form("#student-form", student: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#student-form", student: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.student_index_path(conn, :index))

      assert html =~ "Student created successfully"
      assert html =~ "some first_name"
    end

    test "updates student in listing", %{conn: conn, student: student} do
      {:ok, index_live, _html} = live(conn, Routes.student_index_path(conn, :index))

      assert index_live |> element("#student-#{student.id} a", "Edit") |> render_click() =~
               "Edit Student"

      assert_patch(index_live, Routes.student_index_path(conn, :edit, student))

      assert index_live
             |> form("#student-form", student: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#student-form", student: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.student_index_path(conn, :index))

      assert html =~ "Student updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes student in listing", %{conn: conn, student: student} do
      {:ok, index_live, _html} = live(conn, Routes.student_index_path(conn, :index))

      assert index_live |> element("#student-#{student.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#student-#{student.id}")
    end
  end

  describe "Show" do
    setup [:create_student]

    test "displays student", %{conn: conn, student: student} do
      {:ok, _show_live, html} = live(conn, Routes.student_show_path(conn, :show, student))

      assert html =~ "Show Student"
      assert html =~ student.first_name
    end

    test "updates student within modal", %{conn: conn, student: student} do
      {:ok, show_live, _html} = live(conn, Routes.student_show_path(conn, :show, student))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Student"

      assert_patch(show_live, Routes.student_show_path(conn, :edit, student))

      assert show_live
             |> form("#student-form", student: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#student-form", student: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.student_show_path(conn, :show, student))

      assert html =~ "Student updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
