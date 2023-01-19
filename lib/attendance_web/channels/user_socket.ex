defmodule AttendanceWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: AttendanceApi.Schema
  alias Attendance.Lecturers.Lecturer
  alias Attendance.Students.Student

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  # Uncomment the following line to define a "room:*" topic
  # pointing to the `AttendanceWeb.RoomChannel`:

  channel "attendance:*", AttendanceWeb.AttendanceChannel

  # To create a channel file, use the mix task:
  #
  #     mix phx.gen.channel Room
  #
  # See the [`Channels guide`](https://hexdocs.pm/phoenix/channels.html)
  # for further details.

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"authorization" => header_content}, socket, _connect_info) do
    [[_, token]] = Regex.scan(~r/^Bearer (.*)/, header_content)
    token = Base.url_decode64(token, padding: false)
    student = Attendance.Students.get_student_by_session_token(elem(token, 1))
    lecturer = Attendance.Lecturers.get_lecturer_by_session_token(elem(token, 1))

    cond do
      student != nil ->
        current_u = current_user(student)

        socket =
          Absinthe.Phoenix.Socket.put_options(socket, context: %{current_student: current_u})

        {:ok, socket}

      lecturer != nil ->
        current_user = current_user(lecturer)

        socket =
          Absinthe.Phoenix.Socket.put_options(socket, context: %{current_lecturer: current_user})

        {:ok, socket}
    end
  end

  def connect(_params, _socket), do: :error

  defp current_user(params) do
    cond do
      params.account_type == "lecturer" ->
        Attendance.Repo.get(Lecturer, params.id)

      params.account_type == "student" ->
        Attendance.Repo.get(Student, params.id)
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.AttendanceWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
