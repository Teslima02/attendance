defmodule AttendanceWeb.SessionLive.AssignCourseFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog
  alias Attendance.Lecturers
  alias Attendance.Lecturers.Lecturer

  @impl true
  # def update(%{assign_lecturer: assign_lecturer} = assigns, socket) do
    def update(%{courses: courses} = assigns, socket) do
    changeset = Catalog.change_courses(courses)
    # changeset = Lecturers.change_assign_course_to_lecturer(%Lecturer{}, assign_lecturer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}

  end


  @impl true
  def handle_event("validate", %{"courses" => courses_params}, socket) do
    changeset =
      socket.assigns.courses
      |> Catalog.change_courses(courses_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"courses" => courses_params}, socket) do
    assign_courses(socket, socket.assigns.action, courses_params)
  end

  defp assign_courses(socket, :assign_course, courses_params) do
    %{
      assigns: %{
        courses: %{
          id: course_id
        }
      }
    } = socket
    %{"lecturer_id" => lecturer_id} = courses_params

    course = Catalog.get_courses!(course_id)
    lecturer = Lecturers.get_lecturer!(lecturer_id)

    # IO.inspect course
    # IO.inspect lecturer
    case Lecturers.change_assign_course_to_lecturer(course, lecturer) do
      {:ok, _courses} ->
        {:noreply,
         socket
         |> put_flash(:info, "Courses assigned successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
