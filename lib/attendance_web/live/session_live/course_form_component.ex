defmodule AttendanceWeb.SessionLive.CourseFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog

  @impl true
  def update(%{course: course} = assigns, socket) do
    changeset = Catalog.change_courses(course)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"courses" => courses_params}, socket) do
    changeset =
      socket.assigns.course
      |> Catalog.change_courses(courses_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"courses" => courses_params}, socket) do
    save_courses(socket, socket.assigns.action, courses_params)
  end

  defp save_courses(socket, :edit_course, courses_params) do
    case Catalog.update_courses(socket.assigns.course, courses_params) do
      {:ok, _courses} ->
        {:noreply,
         socket
         |> put_flash(:info, "Courses updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
