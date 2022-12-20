defmodule AttendanceApi.Middleware.LecturerAuth do
  @behaviour Absinthe.Middleware
  alias Attendance.Lecturers.Lecturer

  def call(resolution, _opts) do
    with %{current_lecturer: %Lecturer{} = _lecturer} <- resolution.context do
      resolution
    else
      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Not authorized"})
    end
  end
end
