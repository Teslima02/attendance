defmodule AttendanceWeb.ProgramLive.FormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog

  @impl true
  def update(%{program: program} = assigns, socket) do
    changeset = Catalog.change_program(program)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"program" => program_params}, socket) do
    changeset =
      socket.assigns.program
      |> Catalog.change_program(program_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"program" => program_params}, socket) do
    save_program(socket, socket.assigns.action, program_params)
  end

  defp save_program(socket, :edit, program_params) do
    case Catalog.update_program(socket.assigns.program, program_params) do
      {:ok, _program} ->
        {:noreply,
         socket
         |> put_flash(:info, "Program updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_program(socket, :new, program_params) do
    case Catalog.create_program(socket.assigns.current_admin, program_params) do
      {:ok, _program} ->
        {:noreply,
         socket
         |> put_flash(:info, "Program created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
