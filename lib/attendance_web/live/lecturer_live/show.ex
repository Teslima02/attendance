defmodule AttendanceWeb.LecturerLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Lecturers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lecturer, Lecturers.get_lecturer!(id))}
  end

  defp page_title(:show), do: "Show Lecturer"
  defp page_title(:edit), do: "Edit Lecturer"
end
