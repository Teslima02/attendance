defmodule AttendanceWeb.Lecturer_hallLiveTest do
  use AttendanceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Attendance.Lecturer_hallsFixtures

  @create_attrs %{building_name: "some building_name", disabled: true, hall_number: "some hall_number"}
  @update_attrs %{building_name: "some updated building_name", disabled: false, hall_number: "some updated hall_number"}
  @invalid_attrs %{building_name: nil, disabled: false, hall_number: nil}

  defp create_lecturer_hall(_) do
    lecturer_hall = lecturer_hall_fixture()
    %{lecturer_hall: lecturer_hall}
  end

  describe "Index" do
    setup [:create_lecturer_hall]

    test "lists all lecturer_halls", %{conn: conn, lecturer_hall: lecturer_hall} do
      {:ok, _index_live, html} = live(conn, Routes.lecturer_hall_index_path(conn, :index))

      assert html =~ "Listing Lecturer halls"
      assert html =~ lecturer_hall.building_name
    end

    test "saves new lecturer_hall", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.lecturer_hall_index_path(conn, :index))

      assert index_live |> element("a", "New Lecturer hall") |> render_click() =~
               "New Lecturer hall"

      assert_patch(index_live, Routes.lecturer_hall_index_path(conn, :new))

      assert index_live
             |> form("#lecturer_hall-form", lecturer_hall: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#lecturer_hall-form", lecturer_hall: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.lecturer_hall_index_path(conn, :index))

      assert html =~ "Lecturer hall created successfully"
      assert html =~ "some building_name"
    end

    test "updates lecturer_hall in listing", %{conn: conn, lecturer_hall: lecturer_hall} do
      {:ok, index_live, _html} = live(conn, Routes.lecturer_hall_index_path(conn, :index))

      assert index_live |> element("#lecturer_hall-#{lecturer_hall.id} a", "Edit") |> render_click() =~
               "Edit Lecturer hall"

      assert_patch(index_live, Routes.lecturer_hall_index_path(conn, :edit, lecturer_hall))

      assert index_live
             |> form("#lecturer_hall-form", lecturer_hall: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#lecturer_hall-form", lecturer_hall: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.lecturer_hall_index_path(conn, :index))

      assert html =~ "Lecturer hall updated successfully"
      assert html =~ "some updated building_name"
    end

    test "deletes lecturer_hall in listing", %{conn: conn, lecturer_hall: lecturer_hall} do
      {:ok, index_live, _html} = live(conn, Routes.lecturer_hall_index_path(conn, :index))

      assert index_live |> element("#lecturer_hall-#{lecturer_hall.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lecturer_hall-#{lecturer_hall.id}")
    end
  end

  describe "Show" do
    setup [:create_lecturer_hall]

    test "displays lecturer_hall", %{conn: conn, lecturer_hall: lecturer_hall} do
      {:ok, _show_live, html} = live(conn, Routes.lecturer_hall_show_path(conn, :show, lecturer_hall))

      assert html =~ "Show Lecturer hall"
      assert html =~ lecturer_hall.building_name
    end

    test "updates lecturer_hall within modal", %{conn: conn, lecturer_hall: lecturer_hall} do
      {:ok, show_live, _html} = live(conn, Routes.lecturer_hall_show_path(conn, :show, lecturer_hall))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Lecturer hall"

      assert_patch(show_live, Routes.lecturer_hall_show_path(conn, :edit, lecturer_hall))

      assert show_live
             |> form("#lecturer_hall-form", lecturer_hall: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#lecturer_hall-form", lecturer_hall: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.lecturer_hall_show_path(conn, :show, lecturer_hall))

      assert html =~ "Lecturer hall updated successfully"
      assert html =~ "some updated building_name"
    end
  end
end
