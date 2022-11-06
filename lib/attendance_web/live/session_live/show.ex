defmodule AttendanceWeb.SessionLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  import AttendanceWeb.ProgramLive.Index

  @impl true
  def mount(_params, %{"admin_token" => token} = _session, socket) do
    {:ok, 
    socket
    |> assign_programs()
    |> assign_current_admin(token)
  }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:session, Catalog.get_session!(id))}
  end

  defp page_title(:show), do: "Show Session"
  defp page_title(:edit), do: "Edit Session"
end
