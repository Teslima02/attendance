defmodule AttendanceWeb.CoursesLive.FormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Category

  @impl true
  def update(%{courses: courses} = assigns, socket) do
    changeset = Category.change_courses(courses)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"courses" => courses_params}, socket) do
    changeset =
      socket.assigns.courses
      |> Category.change_courses(courses_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"courses" => courses_params}, socket) do
    save_courses(socket, socket.assigns.action, courses_params)
  end

  defp save_courses(socket, :edit, courses_params) do
    case Category.update_courses(socket.assigns.courses, courses_params) do
      {:ok, _courses} ->
        {:noreply,
         socket
         |> put_flash(:info, "Courses updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_courses(socket, :new, courses_params) do
    case Category.create_courses(courses_params) do
      {:ok, _courses} ->
        {:noreply,
         socket
         |> put_flash(:info, "Courses created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
