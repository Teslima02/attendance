defmodule AttendanceWeb.SessionLive.ShowSemester do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_semesters()}
  end

  def assign_semesters(socket) do
    socket
    |> assign(semesters: list_semesters())
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_semester, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id,
         "semester_id" => semester_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:semester, Catalog.get_semester!(semester_id))
    end
  end

  defp apply_action(socket, :edit_semester, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id,
         "semester_id" => semester_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:semester, Catalog.get_semester!(semester_id))
    end
  end

  defp page_title(:show_semester), do: "Show Semester"
  defp page_title(:edit_semester), do: "Edit Semester"

  defp list_semesters do
    Catalog.list_semesters()
  end
end
