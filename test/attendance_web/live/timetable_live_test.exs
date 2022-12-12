defmodule AttendanceWeb.TimetableLiveTest do
  use AttendanceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Attendance.TimetablesFixtures

  @create_attrs %{disabled: true, end_time: %{hour: 14, minute: 0}, start_time: %{hour: 14, minute: 0}}
  @update_attrs %{disabled: false, end_time: %{hour: 15, minute: 1}, start_time: %{hour: 15, minute: 1}}
  @invalid_attrs %{disabled: false, end_time: %{hour: 14, minute: 0}, start_time: %{hour: 14, minute: 0}}

  defp create_timetable(_) do
    timetable = timetable_fixture()
    %{timetable: timetable}
  end

  describe "Index" do
    setup [:create_timetable]

    test "lists all timetables", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.timetable_index_path(conn, :index))

      assert html =~ "Listing Timetables"
    end

    test "saves new timetable", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.timetable_index_path(conn, :index))

      assert index_live |> element("a", "New Timetable") |> render_click() =~
               "New Timetable"

      assert_patch(index_live, Routes.timetable_index_path(conn, :new))

      assert index_live
             |> form("#timetable-form", timetable: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#timetable-form", timetable: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.timetable_index_path(conn, :index))

      assert html =~ "Timetable created successfully"
    end

    test "updates timetable in listing", %{conn: conn, timetable: timetable} do
      {:ok, index_live, _html} = live(conn, Routes.timetable_index_path(conn, :index))

      assert index_live |> element("#timetable-#{timetable.id} a", "Edit") |> render_click() =~
               "Edit Timetable"

      assert_patch(index_live, Routes.timetable_index_path(conn, :edit, timetable))

      assert index_live
             |> form("#timetable-form", timetable: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#timetable-form", timetable: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.timetable_index_path(conn, :index))

      assert html =~ "Timetable updated successfully"
    end

    test "deletes timetable in listing", %{conn: conn, timetable: timetable} do
      {:ok, index_live, _html} = live(conn, Routes.timetable_index_path(conn, :index))

      assert index_live |> element("#timetable-#{timetable.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#timetable-#{timetable.id}")
    end
  end

  describe "Show" do
    setup [:create_timetable]

    test "displays timetable", %{conn: conn, timetable: timetable} do
      {:ok, _show_live, html} = live(conn, Routes.timetable_show_path(conn, :show, timetable))

      assert html =~ "Show Timetable"
    end

    test "updates timetable within modal", %{conn: conn, timetable: timetable} do
      {:ok, show_live, _html} = live(conn, Routes.timetable_show_path(conn, :show, timetable))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Timetable"

      assert_patch(show_live, Routes.timetable_show_path(conn, :edit, timetable))

      assert show_live
             |> form("#timetable-form", timetable: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#timetable-form", timetable: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.timetable_show_path(conn, :show, timetable))

      assert html =~ "Timetable updated successfully"
    end
  end
end
