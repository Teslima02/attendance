defmodule AttendanceWeb.SessionLive.AssignCourseFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog
  alias Attendance.Lecturers

  @impl true
  def update(%{assign_course_to_lecturer: %{course: course_id}} = assigns, socket) do
    course = Catalog.get_courses!(course_id)
    changeset = Catalog.change_courses(course)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"course" => courses_params}, socket) do
    changeset =
      socket.assigns.course
      |> Catalog.change_courses(courses_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"course" => courses_params}, socket) do
    assign_courses(socket, socket.assigns.action, courses_params)
  end

  defp assign_courses(socket, :assign_course, courses_params) do
    %{
      assigns: %{
        course: %{
          id: course_id
        }
      }
    } = socket

    %{"lecturer_id" => lecturer_id} = courses_params

    course = Catalog.get_courses!(course_id)
    lecturer = Lecturers.get_lecturer!(lecturer_id)

    case Lecturers.assign_course_to_lecturer(course, lecturer) do
      {:ok, _courses} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course assigned successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
