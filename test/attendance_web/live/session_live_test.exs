defmodule AttendanceWeb.SessionLiveTest do
  use AttendanceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Attendance.CatalogFixtures

  @create_attrs %{description: "some description", disabled: true, end_date: %{day: 4, hour: 16, minute: 25, month: 11, year: 2022}, name: "some name", start_date: %{day: 4, hour: 16, minute: 25, month: 11, year: 2022}}
  @update_attrs %{description: "some updated description", disabled: false, end_date: %{day: 5, hour: 16, minute: 25, month: 11, year: 2022}, name: "some updated name", start_date: %{day: 5, hour: 16, minute: 25, month: 11, year: 2022}}
  @invalid_attrs %{description: nil, disabled: false, end_date: %{day: 30, hour: 16, minute: 25, month: 2, year: 2022}, name: nil, start_date: %{day: 30, hour: 16, minute: 25, month: 2, year: 2022}}

  defp create_session(_) do
    session = session_fixture()
    %{session: session}
  end

  describe "Index" do
    setup [:create_session]

    test "lists all sessions", %{conn: conn, session: session} do
      {:ok, _index_live, html} = live(conn, Routes.session_index_path(conn, :index))

      assert html =~ "Listing Sessions"
      assert html =~ session.description
    end

    test "saves new session", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.session_index_path(conn, :index))

      assert index_live |> element("a", "New Session") |> render_click() =~
               "New Session"

      assert_patch(index_live, Routes.session_index_path(conn, :new))

      assert index_live
             |> form("#session-form", session: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#session-form", session: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.session_index_path(conn, :index))

      assert html =~ "Session created successfully"
      assert html =~ "some description"
    end

    test "updates session in listing", %{conn: conn, session: session} do
      {:ok, index_live, _html} = live(conn, Routes.session_index_path(conn, :index))

      assert index_live |> element("#session-#{session.id} a", "Edit") |> render_click() =~
               "Edit Session"

      assert_patch(index_live, Routes.session_index_path(conn, :edit, session))

      assert index_live
             |> form("#session-form", session: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#session-form", session: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.session_index_path(conn, :index))

      assert html =~ "Session updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes session in listing", %{conn: conn, session: session} do
      {:ok, index_live, _html} = live(conn, Routes.session_index_path(conn, :index))

      assert index_live |> element("#session-#{session.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#session-#{session.id}")
    end
  end

  describe "Show" do
    setup [:create_session]

    test "displays session", %{conn: conn, session: session} do
      {:ok, _show_live, html} = live(conn, Routes.session_show_path(conn, :show, session))

      assert html =~ "Show Session"
      assert html =~ session.description
    end

    test "updates session within modal", %{conn: conn, session: session} do
      {:ok, show_live, _html} = live(conn, Routes.session_show_path(conn, :show, session))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Session"

      assert_patch(show_live, Routes.session_show_path(conn, :edit, session))

      assert show_live
             |> form("#session-form", session: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#session-form", session: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.session_show_path(conn, :show, session))

      assert html =~ "Session updated successfully"
      assert html =~ "some updated description"
    end
  end
end
