defmodule AttendanceWeb.Lecturer_hallLive.FormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Lecturer_halls

  @impl true
  def update(%{lecturer_hall: lecturer_hall} = assigns, socket) do
    changeset = Lecturer_halls.change_lecturer_hall(lecturer_hall)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"lecturer_hall" => lecturer_hall_params}, socket) do
    changeset =
      socket.assigns.lecturer_hall
      |> Lecturer_halls.change_lecturer_hall(lecturer_hall_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"lecturer_hall" => lecturer_hall_params}, socket) do
    save_lecturer_hall(socket, socket.assigns.action, lecturer_hall_params)
  end

  defp save_lecturer_hall(socket, :edit, lecturer_hall_params) do
    case Lecturer_halls.update_lecturer_hall(socket.assigns.lecturer_hall, lecturer_hall_params) do
      {:ok, _lecturer_hall} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lecturer hall updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_lecturer_hall(socket, :new, lecturer_hall_params) do
    case Lecturer_halls.create_lecturer_hall(lecturer_hall_params) do
      {:ok, _lecturer_hall} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lecturer hall created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
