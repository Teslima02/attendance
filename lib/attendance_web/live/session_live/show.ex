defmodule AttendanceWeb.SessionLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  alias Attendance.Catalog.Program
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
  def handle_params(%{"id" => id} = params, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:session, Catalog.get_session!(id))
     |> assign(:program, %Program{session_id: id})
    #  |> apply_action(socket.assigns.live_action, params)
  }
  end

  defp apply_action(socket, :edit_program, %{"id" => id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, "Edit Program")
      |> assign(:program, Catalog.get_program!(id))
    end
  end

  defp apply_action(socket, :new_program, _params) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, "New Program")
      |> assign(:program, %Program{})
    end
  end

  defp page_title(:new_program), do: "Create Program"
  defp page_title(:edit_program), do: "Edit Program"
  defp page_title(:show), do: "Show Session"
  defp page_title(:edit), do: "Edit Session"
end
