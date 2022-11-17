defmodule AttendanceWeb.SessionLive.Show do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  alias Attendance.Catalog.{Program, Semester}
  import AttendanceWeb.SessionLive.Index

  @impl true
  def mount(params, %{"admin_token" => token} = _session, socket) do
    IO.inspect params
    {:ok,
     socket
     |> assign_programs(params)
     |> assign_current_admin(token)}
  end

  def assign_programs(socket, params) do
    assign(socket, :programs, list_programs(params))
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_semester, %{"session_id" => session_id} = _params) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, "New Semester")
      |> assign(:semester, %Semester{session_id: session_id})
      |> assign(:session, Catalog.get_session!(session_id))
    end
  end

  defp apply_action(socket, :edit_program, %{"program_id" => program_id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, "Edit Program")
      |> assign(:program, Catalog.get_program!(program_id))
    end
  end

  defp apply_action(socket, :new_program, %{"session_id" => session_id} = _params) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, "New Program")
      |> assign(:program, %Program{session_id: session_id})
      |> assign(:session, Catalog.get_session!(session_id))
    end
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:session, Catalog.get_session!(id))
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:session, Catalog.get_session!(id))
    end
  end

  defp page_title(:new_program), do: "Create Program"
  defp page_title(:edit_program), do: "Edit Program"
  defp page_title(:show), do: "Show Session"
  defp page_title(:edit), do: "Edit Session"

  defp list_programs(params) do
    Catalog.list_programs(params)
  end
end
