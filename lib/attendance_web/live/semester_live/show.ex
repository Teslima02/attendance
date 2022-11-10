defmodule AttendanceWeb.SemesterLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:semester, Catalog.get_semester!(id))}
  end

  defp page_title(:show), do: "Show Semester"
  defp page_title(:edit), do: "Edit Semester"
end
