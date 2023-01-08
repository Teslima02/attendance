defmodule AttendanceWeb.Plug.StudentContext do
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
    with ["Bearer " <> token] <- get_req_header(conn, "Authorization"),
         tok <- Base.url_decode64(token, padding: false),
         student <- Attendance.Students.get_student_by_session_token(elem(tok, 1)) do
      {:ok, %{current_student: student}}
    end
  end
end
