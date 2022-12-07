defmodule AttendanceWeb.SessionLive.UploadStudentFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Students
  alias NimbleCSV.RFC4180, as: CSV

  @impl true
  def update(%{student: student} = assigns, socket) do
    changeset = Students.change_student(student)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:csv_file,
       accept: ~w(.csv),
       max_entries: 1,
       auto_upload: true,
       chunk_size: 64_000
     )}
  end

  def student_csv(file) do
    Application.app_dir(:attendance, "/priv/static/uploads#{file}")
  end

  @impl true
  def handle_event("validate", %{"student" => student_params}, socket) do
    changeset =
      socket.assigns.student
      |> Students.change_student(student_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv_file, ref)}
  end

  # def handle_event("save", %{"student" => student_params}, socket) do
  #   save_student(socket, socket.assigns.action, student_params)
  # end

  def handle_event("save", %{"student" => student_params}, socket) do
    # File upload function
    expected_file = file_upload(socket, :csv_file)

    # Reading CSV File upload function
    students = read_csv_file(expected_file)

    save_student(socket, socket.assigns.action, students, student_params)
  end

  def read_csv_file(csv_file) do
    csv_file
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn row ->
      # [row] = CSV.parse_string(row, skip_headers: false)
      %{
        email: Enum.at(row, 0),
        first_name: Enum.at(row, 1),
        middle_name: Enum.at(row, 2),
        last_name: Enum.at(row, 3),
        matric_number: Enum.at(row, 4),
        password: Enum.at(row, 5)
      }
    end)
  end

  def file_upload(socket, :csv_file) do
    uploaded_files =
      consume_uploaded_entries(socket, :csv_file, fn %{path: path}, _entry ->
        dest = Path.join("priv/static/uploads", Path.basename(path))
        File.cp!(path, dest)
        static_path = Routes.static_path(socket, "/#{Path.basename(dest)}")
        {:ok, static_path}
      end)

    update(socket, :uploaded_files, &(&1 ++ uploaded_files))

    student_csv(uploaded_files)
  end

  defp save_student(socket, :edit_student, _, student_params) do
    case Students.update_student(socket.assigns.student, student_params) do
      {:ok, _student} ->
        {:noreply,
         socket
         |> put_flash(:info, "Student updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_student(socket, :upload_student, students, _student_params) do
    Enum.each(students, fn row ->
      case Students.register_student(socket.assigns.current_admin, socket.assigns.class, %{
             email: row.email,
             password: row.password,
             first_name: row.first_name,
             middle_name: row.middle_name,
             last_name: row.last_name,
             matric_number: row.matric_number
           }) do
        {:ok, _student} ->
          {:noreply,
           socket
           |> put_flash(:info, "Student uploaded successfully")
           |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Student uploaded successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end
end
