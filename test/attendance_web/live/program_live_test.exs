defmodule AttendanceWeb.ProgramLiveTest do
  use AttendanceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Attendance.CatalogFixtures

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  defp create_program(_) do
    program = program_fixture()
    %{program: program}
  end

  describe "Index" do
    setup [:create_program, :register_and_log_in_admin]

    test "lists all programs", %{conn: conn, program: program} do
      {:ok, _index_live, html} = live(conn, Routes.program_index_path(conn, :index))

      assert html =~ "Listing Programs"
      assert html =~ program.description
    end

    test "saves new program", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.program_index_path(conn, :index))

      assert index_live |> element("a", "New Program") |> render_click() =~
               "New Program"

      assert_patch(index_live, Routes.program_index_path(conn, :new))

      assert index_live
             |> form("#program-form", program: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#program-form", program: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.program_index_path(conn, :index))

      assert html =~ "Program created successfully"
      assert html =~ "some description"
    end

    test "updates program in listing", %{conn: conn, program: program} do
      {:ok, index_live, _html} = live(conn, Routes.program_index_path(conn, :index))

      assert index_live |> element("#program-#{program.id} a", "Edit") |> render_click() =~
               "Edit Program"

      assert_patch(index_live, Routes.program_index_path(conn, :edit, program))

      assert index_live
             |> form("#program-form", program: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#program-form", program: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.program_index_path(conn, :index))

      assert html =~ "Program updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes program in listing", %{conn: conn, program: program} do
      {:ok, index_live, _html} = live(conn, Routes.program_index_path(conn, :index))

      assert index_live |> element("#program-#{program.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#program-#{program.id}")
    end
  end

  describe "Show" do
    setup [:create_program, :register_and_log_in_admin]

    test "displays program", %{conn: conn, program: program} do
      {:ok, _show_live, html} = live(conn, Routes.program_show_path(conn, :show, program))

      assert html =~ "Show Program"
      assert html =~ program.description
    end

    test "updates program within modal", %{conn: conn, program: program} do
      {:ok, show_live, _html} = live(conn, Routes.program_show_path(conn, :show, program))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Program"

      assert_patch(show_live, Routes.program_show_path(conn, :edit, program))

      assert show_live
             |> form("#program-form", program: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#program-form", program: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.program_show_path(conn, :show, program))

      assert html =~ "Program updated successfully"
      assert html =~ "some updated description"
    end
  end
end
