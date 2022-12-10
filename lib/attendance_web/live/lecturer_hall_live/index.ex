defmodule AttendanceWeb.Lecturer_hallLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Lecturer_halls
  alias Attendance.Lecturer_halls.Lecturer_hall

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :lecturer_halls, list_lecturer_halls())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lecturer hall")
    |> assign(:lecturer_hall, Lecturer_halls.get_lecturer_hall!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lecturer hall")
    |> assign(:lecturer_hall, %Lecturer_hall{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lecturer halls")
    |> assign(:lecturer_hall, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lecturer_hall = Lecturer_halls.get_lecturer_hall!(id)
    {:ok, _} = Lecturer_halls.delete_lecturer_hall(lecturer_hall)

    {:noreply, assign(socket, :lecturer_halls, list_lecturer_halls())}
  end

  defp list_lecturer_halls do
    Lecturer_halls.list_lecturer_halls()
  end
end
