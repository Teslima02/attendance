defmodule AttendanceWeb.LecturerLive.UploadComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Lecturers
  alias NimbleCSV.RFC4180, as: CSV

  def unique_admin_email, do: "admin#{System.unique_integer()}@example.com"
  @impl true
  def update(%{lecturer: lecturer} = assigns, socket) do
    changeset = Lecturers.change_lecturer(lecturer)

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

  def lecturer_csv(file) do
    Application.app_dir(:attendance, "/priv/static/uploads#{file}")
  end

  @impl true
  def handle_event("validate", %{"lecturer" => lecturer_params}, socket) do
    changeset =
      socket.assigns.lecturer
      |> Lecturers.change_lecturer(lecturer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"lecturer" => lecturer_params}, socket) do
    # File upload function
    expected_file = file_upload(socket, :csv_file)

    # Reading CSV File upload function
    lecturer = read_csv_file(expected_file)

    save_lecturer(socket, socket.assigns.action, lecturer, lecturer_params)
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

  defp attend_config, do: Application.get_env(:attendance, Attend_config)

  def file_upload(socket, :csv_file) do
    uploaded_files =
      consume_uploaded_entries(socket, :csv_file, fn %{path: path}, _entry ->
        # IO.inspect attend_config[:uploads_dir]
        # IO.inspect attend_config[:environment]
        if attend_config[:environment] == :dev do
          dest = Path.join("priv/static/uploads", Path.basename(path))
          File.cp!(path, dest)
          static_path = Routes.static_path(socket, "/#{Path.basename(dest)}")
          {:ok, static_path}
        else
          dest = Path.join("/app/uploads", Path.basename(path))
          File.cp!(path, dest)
          static_path = Routes.static_path(socket, "/#{Path.basename(dest)}")
          {:ok, static_path}
        end
      end)

    update(socket, :uploaded_files, &(&1 ++ uploaded_files))

    lecturer_csv(uploaded_files)
  end

  defp save_lecturer(socket, :edit, _, lecturer_params) do
    case Lecturers.update_lecturer(socket.assigns.lecturer, lecturer_params) do
      {:ok, _lecturer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lecturer updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_lecturer(socket, :upload_lecturer, lecturer, _lecturer_params) do
    Enum.each(lecturer, fn row ->
      case Lecturers.register_lecturer(socket.assigns.current_admin, %{
             email: row.email,
             password: row.password,
             first_name: row.first_name,
             middle_name: row.middle_name,
             last_name: row.last_name,
             matric_number: row.matric_number
           }) do
        {:ok, _lecturer} ->
          {:noreply,
           socket
           |> put_flash(:info, "Lecturer upload successfully")
           |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Lecturer upload successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end
end
