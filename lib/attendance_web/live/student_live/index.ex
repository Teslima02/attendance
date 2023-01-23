defmodule AttendanceWeb.StudentLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Students
  alias Attendance.Students.Student

  @impl true
  def mount(params, _session, socket) do
    IO.inspect params
    IO.inspect "params"
    {:ok, assign(socket, :students, list_students())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Student")
    |> assign(:student, Students.get_student!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Student")
    |> assign(:student, %Student{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Students")
    |> assign(:student, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    student = Students.get_student!(id)
    {:ok, _} = Students.delete_student(student)

    {:noreply, assign(socket, :students, list_students())}
  end

  def list_students do
    Students.list_students() |> Io.inspect
  end
end
