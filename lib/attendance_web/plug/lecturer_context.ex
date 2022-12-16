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
    with ["" <> token] <- get_req_header(conn, "authorization"), tok <- Base.url_decode64(token, padding: false),
         lecturer <- Attendance.Lecturers.LecturerToken.verify_session_token_query(token = elem(tok, 1)) do

      {:ok, %{current_lecturer: lecturer}}
    end
  end
end
