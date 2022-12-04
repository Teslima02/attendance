defmodule AttendanceWeb.SessionLive.ShowSemester do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  alias Attendance.Catalog.Course
  alias Attendance.Lecturers

  import AttendanceWeb.SessionLive.Index

  @impl true
  def mount(params, %{"admin_token" => token} = _session, socket) do
    {:ok,
     socket
     |> assign_courses(params)
     |> assign_current_admin(token)}
  end

  def assign_courses(socket, params) do
    socket
    |> assign(courses: list_courses(params))
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

  defp apply_action(socket, :upload_course, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id,
         "semester_id" => semester_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:courses, %Course{
        session_id: session_id,
        program_id: program_id,
        class_id: class_id,
        semester_id: semester_id
      })
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:semester, Catalog.get_semester!(semester_id))
    end
  end

  defp apply_action(socket, :edit_course, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id,
         "semester_id" => semester_id,
         "course_id" => course_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:semester, Catalog.get_semester!(semester_id))
      |> assign(:course, Catalog.get_courses!(course_id))
    end
  end

  defp apply_action(socket, :assign_course, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id,
         "semester_id" => semester_id,
         "course_id" => course_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:semester, Catalog.get_semester!(semester_id))
      |> assign(:course, Catalog.get_courses!(course_id))
      |> assign(:lecturers, Lecturers.list_lecturers())
      |> assign(:assign_course_to_lecturer, %{
        course: course_id
      })
    end
  end

  defp page_title(:upload_course), do: "Upload New Course"
  defp page_title(:show_semester), do: "Show Semester"
  defp page_title(:edit_semester), do: "Edit Semester"
  defp page_title(:edit_course), do: "Edit Course"
  defp page_title(:assign_course), do: "Assign course to lecturer"
  defp page_title(:assign_course_lecturer), do: "Assign course to lecturer"

  defp list_courses(params) do
    Catalog.list_course(params)
  end
end
