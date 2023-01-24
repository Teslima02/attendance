defmodule AttendanceWeb.Plug.LecturerContext do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      _ ->
        conn
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         tok <- Base.url_decode64(token, padding: false) do

      lecturer = Attendance.Lecturers.get_lecturer_by_session_token(elem(tok, 1))
      student = Attendance.Students.get_student_by_session_token(elem(tok, 1))

      cond do
        lecturer != nil ->
          {:ok, %{current_lecturer: lecturer}}

        student != nil ->
          {:ok, %{current_student: student}}
      end
    end
  end
end
