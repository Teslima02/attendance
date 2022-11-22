defmodule AttendanceWeb.SessionLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Accounts
  alias Attendance.Catalog
  alias Attendance.Catalog.Session

  @impl true
  def mount(_params, %{"admin_token" => token} = _session, socket) do
    {:ok, socket
      |> assign_sessions()
      |> assign_current_admin(token)
    }
  end

  def assign_current_admin(socket, token) do
    assign_new(socket, :current_admin, fn ->
      Accounts.get_admin_by_session_token(token)
    end)
  end

  def assign_sessions(socket) do
    assign(socket, :sessions, list_sessions())
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Session")
    |> assign(:session, Catalog.get_session!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Session")
    |> assign(:session, %Session{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sessions")
    |> assign(:session, nil)
  end

  defp apply_action(socket, :new_program, _params) do
    socket
    |> assign(:page_title, "New Session")
    |> assign(:session, %Session{})
  end

  defp apply_action(socket, :edit_program, _params) do
    socket
    |> assign(:page_title, "Edit Sessions")
    |> assign(:session, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    session = Catalog.get_session!(id)
    {:ok, _} = Catalog.delete_session(session)

    {:noreply, assign(socket, :sessions, list_sessions())}
  end

  defp list_sessions do
    Catalog.list_sessions()
  end
end
