defmodule AttendanceWeb.CoursesLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  alias Attendance.Catalog.Courses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :course, list_course())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Courses")
    |> assign(:courses, Catalog.get_courses!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Courses")
    |> assign(:courses, %Courses{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Course")
    |> assign(:courses, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    courses = Catalog.get_courses!(id)
    {:ok, _} = Catalog.delete_courses(courses)

    {:noreply, assign(socket, :course, list_course())}
  end

  defp list_course do
    Catalog.list_course()
  end
end
