defmodule AttendanceWeb.SessionLive.TimetableFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog
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

  # defp save_timetable(socket, :edit_timetable, timetable_params) do
  #   case Timetables.update_timetable(socket.assigns.timetable, timetable_params) do
  #     {:ok, _timetable} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Timetable updated successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

  defp save_timetable(socket, :create_timetable, %{
         "course_id" => course_id,
         "day_id" => day_id,
         "start_time_id" => start_time_id,
         "end_time_id" => end_time_id,
         "start_time" => start_time,
         "end_time" => end_time,
       } = params) do
        course = Catalog.get_courses!(course_id)
        day = Catalog.get_days_of_week!(day_id)
        start_time = Catalog.get_period!(start_time_id)
        end_time = Catalog.get_period!(end_time_id)
        # semester = Catalog.get_semester!(timetable_params.get_semester_id)
        IO.inspect params
        # IO.inspect start_time.start_time
        # IO.inspect end_time.end_time

    case Timetables.create_timetable(socket.assigns.current_admin, course, day, %{
           stat_time: Time.to_iso8601(start_time.start_time),
           end_time: Time.to_iso8601(end_time.end_time)
          #  stat_time: start_time,
          #  end_time: end_time
         }) do
      {:ok, _timetable} ->
        {:noreply,
         socket
         |> put_flash(:info, "Timetable created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
