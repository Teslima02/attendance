defmodule AttendanceWeb.CoursesLiveTest do
  use AttendanceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Attendance.CategoryFixtures

  @create_attrs %{code: "some code", description: "some description", name: "some name"}
  @update_attrs %{code: "some updated code", description: "some updated description", name: "some updated name"}
  @invalid_attrs %{code: nil, description: nil, name: nil}

  defp create_courses(_) do
    courses = courses_fixture()
    %{courses: courses}
  end

  describe "Index" do
    setup [:create_courses]

    test "lists all course", %{conn: conn, courses: courses} do
      {:ok, _index_live, html} = live(conn, Routes.courses_index_path(conn, :index))

      assert html =~ "Listing Course"
      assert html =~ courses.code
    end

    test "saves new courses", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.courses_index_path(conn, :index))

      assert index_live |> element("a", "New Courses") |> render_click() =~
               "New Courses"

      assert_patch(index_live, Routes.courses_index_path(conn, :new))

      assert index_live
             |> form("#courses-form", courses: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#courses-form", courses: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.courses_index_path(conn, :index))

      assert html =~ "Courses created successfully"
      assert html =~ "some code"
    end

    test "updates courses in listing", %{conn: conn, courses: courses} do
      {:ok, index_live, _html} = live(conn, Routes.courses_index_path(conn, :index))

      assert index_live |> element("#courses-#{courses.id} a", "Edit") |> render_click() =~
               "Edit Courses"

      assert_patch(index_live, Routes.courses_index_path(conn, :edit, courses))

      assert index_live
             |> form("#courses-form", courses: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#courses-form", courses: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.courses_index_path(conn, :index))

      assert html =~ "Courses updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes courses in listing", %{conn: conn, courses: courses} do
      {:ok, index_live, _html} = live(conn, Routes.courses_index_path(conn, :index))

      assert index_live |> element("#courses-#{courses.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#courses-#{courses.id}")
    end
  end

  describe "Show" do
    setup [:create_courses]

    test "displays courses", %{conn: conn, courses: courses} do
      {:ok, _show_live, html} = live(conn, Routes.courses_show_path(conn, :show, courses))

      assert html =~ "Show Courses"
      assert html =~ courses.code
    end

    test "updates courses within modal", %{conn: conn, courses: courses} do
      {:ok, show_live, _html} = live(conn, Routes.courses_show_path(conn, :show, courses))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Courses"

      assert_patch(show_live, Routes.courses_show_path(conn, :edit, courses))

      assert show_live
             |> form("#courses-form", courses: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#courses-form", courses: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.courses_show_path(conn, :show, courses))

      assert html =~ "Courses updated successfully"
      assert html =~ "some updated code"
    end
  end
end
