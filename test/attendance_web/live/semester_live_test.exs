defmodule AttendanceWeb.SemesterLiveTest do
  use AttendanceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Attendance.CatalogFixtures

  @create_attrs %{disabled: true, end_date: %{day: 7, month: 11, year: 2022}, name: "some name", start_date: %{day: 7, month: 11, year: 2022}}
  @update_attrs %{disabled: false, end_date: %{day: 8, month: 11, year: 2022}, name: "some updated name", start_date: %{day: 8, month: 11, year: 2022}}
  @invalid_attrs %{disabled: false, end_date: %{day: 30, month: 2, year: 2022}, name: nil, start_date: %{day: 30, month: 2, year: 2022}}

  defp create_semester(_) do
    semester = semester_fixture()
    %{semester: semester}
  end

  describe "Index" do
    setup [:create_semester]

    test "lists all semesters", %{conn: conn, semester: semester} do
      {:ok, _index_live, html} = live(conn, Routes.semester_index_path(conn, :index))

      assert html =~ "Listing Semesters"
      assert html =~ semester.name
    end

    test "saves new semester", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.semester_index_path(conn, :index))

      assert index_live |> element("a", "New Semester") |> render_click() =~
               "New Semester"

      assert_patch(index_live, Routes.semester_index_path(conn, :new))

      assert index_live
             |> form("#semester-form", semester: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#semester-form", semester: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.semester_index_path(conn, :index))

      assert html =~ "Semester created successfully"
      assert html =~ "some name"
    end

    test "updates semester in listing", %{conn: conn, semester: semester} do
      {:ok, index_live, _html} = live(conn, Routes.semester_index_path(conn, :index))

      assert index_live |> element("#semester-#{semester.id} a", "Edit") |> render_click() =~
               "Edit Semester"

      assert_patch(index_live, Routes.semester_index_path(conn, :edit, semester))

      assert index_live
             |> form("#semester-form", semester: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#semester-form", semester: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.semester_index_path(conn, :index))

      assert html =~ "Semester updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes semester in listing", %{conn: conn, semester: semester} do
      {:ok, index_live, _html} = live(conn, Routes.semester_index_path(conn, :index))

      assert index_live |> element("#semester-#{semester.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#semester-#{semester.id}")
    end
  end

  describe "Show" do
    setup [:create_semester]

    test "displays semester", %{conn: conn, semester: semester} do
      {:ok, _show_live, html} = live(conn, Routes.semester_show_path(conn, :show, semester))

      assert html =~ "Show Semester"
      assert html =~ semester.name
    end

    test "updates semester within modal", %{conn: conn, semester: semester} do
      {:ok, show_live, _html} = live(conn, Routes.semester_show_path(conn, :show, semester))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Semester"

      assert_patch(show_live, Routes.semester_show_path(conn, :edit, semester))

      assert show_live
             |> form("#semester-form", semester: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#semester-form", semester: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.semester_show_path(conn, :show, semester))

      assert html =~ "Semester updated successfully"
      assert html =~ "some updated name"
    end
  end
end
