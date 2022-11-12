defmodule AttendanceWeb.SessionLive.SemesterFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog

  @impl true
  def update(%{semester: semester} = assigns, socket) do
    changeset = Catalog.change_semester(semester)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"semester" => semester_params}, socket) do
    changeset =
      socket.assigns.semester
      |> Catalog.change_semester(semester_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"semester" => semester_params}, socket) do
    save_semester(socket, socket.assigns.action, semester_params)
  end

  defp save_semester(socket, :edit_semester, semester_params) do
    case Catalog.update_semester(socket.assigns.semester, semester_params) do
      {:ok, _semester} ->
        {:noreply,
         socket
         |> put_flash(:info, "Semester updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_semester(socket, :new_semester, semester_params) do
    %{assigns: %{semester: %{session_id: session_id, program_id: program_id, class_id: class_id}}} = socket
    session = Catalog.get_session!(session_id)
    program = Catalog.get_program!(program_id)
    class = Catalog.get_class!(class_id)
    case Catalog.create_semester(socket.assigns.current_admin, session, program, class, semester_params) do
      {:ok, _semester} ->
        {:noreply,
         socket
         |> put_flash(:info, "Semester created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
