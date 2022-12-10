defmodule AttendanceWeb.TimetableLive.FormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Timetables

  @impl true
  def update(%{timetable: timetable} = assigns, socket) do
    changeset = Timetables.change_timetable(timetable)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"timetable" => timetable_params}, socket) do
    changeset =
      socket.assigns.timetable
      |> Timetables.change_timetable(timetable_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"timetable" => timetable_params}, socket) do
    save_timetable(socket, socket.assigns.action, timetable_params)
  end

  defp save_timetable(socket, :edit, timetable_params) do
    case Timetables.update_timetable(socket.assigns.timetable, timetable_params) do
      {:ok, _timetable} ->
        {:noreply,
         socket
         |> put_flash(:info, "Timetable updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  # defp save_timetable(socket, :new, timetable_params) do
  #   case Timetables.create_timetable(timetable_params) do
  #     {:ok, _timetable} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Timetable created successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, changeset: changeset)}
  #   end
  # end
end
