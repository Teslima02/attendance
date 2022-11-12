defmodule AttendanceWeb.SessionLive.ShowClass do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_classes()}
  end

  def assign_classes(socket) do
    socket
    |> assign(classes: list_classes())
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_class, %{"session_id" => session_id, "program_id" => program_id, "class_id" => class_id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:class, Catalog.get_class!(class_id))
     |> assign(:program, Catalog.get_program!(program_id))
     |> assign(:session, Catalog.get_session!(session_id))
    end
  end

  defp apply_action(socket, :edit_class, %{"session_id" => session_id, "program_id" => program_id, "class_id" => class_id}) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:class, Catalog.get_class!(class_id))
     |> assign(:program, Catalog.get_program!(program_id))
     |> assign(:session, Catalog.get_session!(session_id))
    end
  end

  defp page_title(:show_class), do: "Show Class"
  defp page_title(:edit_class), do: "Edit Class"

  defp list_classes do
    Catalog.list_classes()
  end
end
