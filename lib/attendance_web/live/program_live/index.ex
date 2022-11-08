defmodule AttendanceWeb.ProgramLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.{Catalog, Accounts}
  alias Attendance.Catalog.Program

  @impl true
  def mount(_params, %{"admin_token" => token} = _session, socket) do
    {:ok,
     socket
     |> assign_programs()
     |> assign_current_admin(token)
    }
  end

  def assign_programs(socket) do
    assign(socket, :programs, list_programs())
  end

  def assign_current_admin(socket, token) do
    assign_new(socket, :current_admin, fn ->
      Accounts.get_admin_by_session_token(token)
    end)
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.inspect params
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Program")
    |> assign(:program, Catalog.get_program!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Program")
    |> assign(:program, %Program{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Programs")
    |> assign(:program, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    program = Catalog.get_program!(id)
    {:ok, _} = Catalog.delete_program(program)

    {:noreply, assign(socket, :programs, list_programs())}
  end

  defp list_programs do
    Catalog.list_programs()
  end
end
