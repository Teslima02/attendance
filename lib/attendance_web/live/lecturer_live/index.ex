defmodule AttendanceWeb.LecturerLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Lecturers
  alias Attendance.Lecturers.Lecturer

  import AttendanceWeb.SessionLive.Index

  @impl true
  def mount(_params, %{"admin_token" => token} = _session, socket) do
    {:ok, socket
    |> assign_lecturers()
    |> assign_current_admin(token)}
  end

  def assign_lecturers(socket) do
    socket
    |> assign(lecturers: list_lecturers())
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lecturer")
    |> assign(:lecturer, Lecturers.get_lecturer!(id))
  end

  defp apply_action(socket, :upload_lecturer, _params) do
    socket
    |> assign(:page_title, "New Lecturer")
    |> assign(:lecturer, %Lecturer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lecturers")
    |> assign(:lecturer, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lecturer = Lecturers.get_lecturer!(id)
    {:ok, _} = Lecturers.delete_lecturer(lecturer)

    {:noreply, assign(socket, :lecturers, list_lecturers())}
  end

  defp list_lecturers do
    Lecturers.list_lecturers()
  end
end
