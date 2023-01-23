defmodule AttendanceWeb.SessionLive.ShowStudent do
  use AttendanceWeb, :live_view

  alias Attendance.Students
  alias Attendance.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    IO.inspect params
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_student, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id,
         "student_id" => student_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:student, Students.get_student!(student_id))
    end
  end

  defp apply_action(socket, :edit_student, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id,
         "student_id" => student_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:student, Students.get_student!(student_id))
    end
  end

  defp page_title(:show_student), do: "Show Student"
  defp page_title(:edit_student), do: "Edit Student"
end
