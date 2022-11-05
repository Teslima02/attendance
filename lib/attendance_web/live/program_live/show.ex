defmodule AttendanceWeb.ProgramLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:program, Catalog.get_program!(id))}
  end

  defp page_title(:show), do: "Show Program"
  defp page_title(:edit), do: "Edit Program"
end
