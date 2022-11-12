defmodule AttendanceWeb.SessionLive.ShowProgram do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog.Class
  alias Attendance.Catalog

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign_session(params)
    }
  end

  def assign_session(socket, %{"session_id" => session_id}) do
      socket
      |> assign(:session, Catalog.get_session!(session_id))
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_program, %{"id" => id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:program, Catalog.get_program!(id))
    end
  end

  defp apply_action(socket, :edit_program, %{"id" => id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:program, Catalog.get_program!(id))
    end
  end

  defp apply_action(socket, :new_class, %{"session_id" => session_id}) do
    # IO.inspect program_id
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:program, Catalog.get_program!(session_id))
      |> assign(:class, %Class{})
    end
  end

  defp page_title(:new_class), do: "New Class"
  defp page_title(:edit_class), do: "Edit Class"
  defp page_title(:show_program), do: "Show Program"
  defp page_title(:edit_program), do: "Edit Program"
end
