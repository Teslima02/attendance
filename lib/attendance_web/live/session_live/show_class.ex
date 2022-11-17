defmodule AttendanceWeb.SessionLive.ShowClass do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  alias Attendance.Catalog.Semester

  import AttendanceWeb.SessionLive.Index
  # import AttendanceWeb.SessionLive.ShowSemester

  @impl true
  def mount(params, %{"admin_token" => token} = _session, socket) do
    {:ok,
     socket
    #  |> assign_classes()
     |> assign_semesters(params)
     |> assign_current_admin(token)}
  end

  def assign_semesters(socket, params) do
    socket
    |> assign(semesters: list_semesters(params))
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_class, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:session, Catalog.get_session!(session_id))
    end
  end

  defp apply_action(socket, :edit_class, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
      |> assign(:session, Catalog.get_session!(session_id))
    end
  end

  defp apply_action(socket, :new_semester, %{
         "session_id" => session_id,
         "program_id" => program_id,
         "class_id" => class_id
       }) do
    if socket.assigns.live_action do
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:semester, %Semester{
        session_id: session_id,
        program_id: program_id,
        class_id: class_id
      })
      |> assign(:session, Catalog.get_session!(session_id))
      |> assign(:class, Catalog.get_class!(class_id))
      |> assign(:program, Catalog.get_program!(program_id))
    end
  end

  defp page_title(:new_semester), do: "New Semester"
  defp page_title(:show_class), do: "Show Class"
  defp page_title(:edit_class), do: "Edit Class"

  defp list_semesters(params) do
    Catalog.list_semesters(params)
  end
end
