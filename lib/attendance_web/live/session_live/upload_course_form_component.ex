defmodule AttendanceWeb.SessionLive.UploadCourseFormComponent do
  use AttendanceWeb, :live_component

  alias Attendance.Catalog
  alias NimbleCSV.RFC4180, as: CSV

  @impl true
  def update(%{course: course} = assigns, socket) do
    changeset = Catalog.change_courses(course)

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

  def courses_csv(file) do
    Application.app_dir(:attendance, "/priv/static/uploads#{file}")
  end

  defp attend_config, do: Application.get_env(:attendance, Attend_config)

  @impl true
  def handle_event("validate", %{"course" => courses_params}, socket) do
    changeset =
      socket.assigns.course
      |> Catalog.change_courses(courses_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv_file, ref)}
  end

  def handle_event("save", %{"course" => courses_params}, socket) do
    # File upload function
    expected_file = file_upload(socket, :csv_file)

    # Reading CSV File upload function
    courses = read_csv_file(expected_file)

    save_courses(socket, socket.assigns.action, courses, courses_params)
  end

  def read_csv_file(csv_file) do
    csv_file
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn row ->
      # [row] = CSV.parse_string(row, skip_headers: false)
      %{
        title: Enum.at(row, 0),
        code: Enum.at(row, 1),
        description: Enum.at(row, 2)
      }
    end)
  end

  def file_upload(socket, :csv_file) do
    uploaded_files =
      consume_uploaded_entries(socket, :csv_file, fn %{path: path}, _entry ->
        if attend_config[:environment] == :prod do
          dest = Path.join("/app/uploads", Path.basename(path))
          File.cp!(path, dest)
          static_path = "/app/uploads/#{Path.basename(dest)}"
          {:ok, static_path}
        else
          dest = Path.join("priv/static/uploads", Path.basename(path))
          File.cp!(path, dest)
          static_path = Routes.static_path(socket, "/#{Path.basename(dest)}")
          {:ok, static_path}
        end
      end)

    update(socket, :uploaded_files, &(&1 ++ uploaded_files))

    if attend_config[:environment] == :prod do
      uploaded_files
    else
      courses_csv(uploaded_files)
    end
  end

  defp save_courses(socket, :edit_course, _courses, courses_params) do
    case Catalog.update_courses(socket.assigns.courses, courses_params) do
      {:ok, _courses} ->
        {:noreply,
         socket
         |> put_flash(:info, "Courses updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_courses(socket, :upload_course, courses, _courses_params) do
    %{
      assigns: %{
        course: %{
          session_id: session_id,
          program_id: program_id,
          class_id: class_id,
          semester_id: semester_id
        }
      }
    } = socket

    session = Catalog.get_session!(session_id)
    program = Catalog.get_program!(program_id)
    class = Catalog.get_class!(class_id)
    semester = Catalog.get_semester!(semester_id)

    Enum.each(courses, fn row ->
      case Catalog.create_courses(
             socket.assigns.current_admin,
             session,
             program,
             class,
             semester,
             %{
               code: row.code,
               name: row.title,
               description: row.description
             }
           ) do
        {:ok, _courses} ->
          {:noreply,
           socket
           |> put_flash(:info, "Courses created successfully")
           |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Courses created successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end
end
