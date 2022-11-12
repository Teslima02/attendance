defmodule AttendanceWeb.SemesterLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  alias Attendance.Catalog.Semester
  import AttendanceWeb.ProgramLive.Index

  @impl true
  def mount(_params, %{"admin_token" => token} = _session, socket) do
    {:ok,
     socket
     |> assign_semesters()
     |> assign_current_admin(token)
    }
  end

  def assign_semesters(socket) do
    assign(socket, :semesters, list_semesters())
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:semester, Catalog.get_semester!(id))
  end

  defp apply_action(socket, :new, %{"session_id" => session_id} = _params) do
    socket
    |> assign(:page_title, "New Semester")
    |> assign(:semester, %Semester{session_id: session_id})
    |> assign(:session, Catalog.get_session!(session_id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Semesters")
    |> assign(:semester, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    semester = Catalog.get_semester!(id)
    {:ok, _} = Catalog.delete_semester(semester)

    {:noreply, assign(socket, :semesters, list_semesters())}
  end

  defp list_semesters do
    Catalog.list_semesters()
  end
end
