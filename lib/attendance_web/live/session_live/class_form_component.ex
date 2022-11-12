defmodule AttendanceWeb.SessionLive.ClassFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog

  @impl true
  def update(%{class: class} = assigns, socket) do
    changeset = Catalog.change_class(class)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"class" => class_params}, socket) do
    changeset =
      socket.assigns.class
      |> Catalog.change_class(class_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"class" => class_params}, socket) do
    save_class(socket, socket.assigns.action, class_params)
  end

  defp save_class(socket, :edit_class, class_params) do
    case Catalog.update_class(socket.assigns.class, class_params) do
      {:ok, _class} ->
        {:noreply,
         socket
         |> put_flash(:info, "Class updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_class(socket, :new_class, class_params) do
    %{assigns: %{class: %{session_id: session_id, program_id: program_id}}} = socket
    session = Catalog.get_session!(session_id)
    program = Catalog.get_program!(program_id)
    case Catalog.create_class(socket.assigns.current_admin, session, program, class_params) do
      {:ok, _class} ->
        {:noreply,
         socket
         |> put_flash(:info, "Class created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
