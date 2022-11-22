defmodule AttendanceWeb.LecturerLive.FormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Lecturers

  @impl true
  def update(%{lecturer: lecturer} = assigns, socket) do
    changeset = Lecturers.change_lecturer(lecturer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"lecturer" => lecturer_params}, socket) do
    changeset =
      socket.assigns.lecturer
      |> Lecturers.change_lecturer(lecturer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"lecturer" => lecturer_params}, socket) do
    save_lecturer(socket, socket.assigns.action, lecturer_params)
  end

  defp save_lecturer(socket, :edit, lecturer_params) do
    case Lecturers.update_lecturer(socket.assigns.lecturer, lecturer_params) do
      {:ok, _lecturer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lecturer updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
