defmodule AttendanceWeb.Lecturer_hallLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Lecturer_halls

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lecturer_hall, Lecturer_halls.get_lecturer_hall!(id))}
  end

  defp page_title(:show), do: "Show Lecturer hall"
  defp page_title(:edit), do: "Edit Lecturer hall"
end
