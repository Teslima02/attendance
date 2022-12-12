defmodule AttendanceWeb.TimetableLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Timetables

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:timetable, Timetables.get_timetable!(id))}
  end

  defp page_title(:show), do: "Show Timetable"
  defp page_title(:edit), do: "Edit Timetable"
end
