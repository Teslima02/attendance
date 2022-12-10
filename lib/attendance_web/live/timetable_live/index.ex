defmodule AttendanceWeb.TimetableLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Timetables
  alias Attendance.Timetables.Timetable

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :timetables, list_timetables())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Timetable")
    |> assign(:timetable, Timetables.get_timetable!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Timetable")
    |> assign(:timetable, %Timetable{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Timetables")
    |> assign(:timetable, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    timetable = Timetables.get_timetable!(id)
    {:ok, _} = Timetables.delete_timetable(timetable)

    {:noreply, assign(socket, :timetables, list_timetables())}
  end

  defp list_timetables do
    Timetables.list_timetables()
  end
end
