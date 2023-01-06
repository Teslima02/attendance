defmodule AttendanceApi.Middleware.StudentAuth do
  @behaviour Absinthe.Middleware
  alias Attendance.Students.Student

  def call(resolution, _opts) do
    with %{current_student: %Student{} = _student} <- resolution.context do
      resolution
    else
      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Not authorized"})
    end
  end
end
