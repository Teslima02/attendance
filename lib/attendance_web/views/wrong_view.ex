defmodule AttendanceWeb.WrongView do
  use AttendanceWeb, :live_view

  def mount(_params, session, socket) do
    IO.inspect(session)

    {:ok,
     assign(socket,
       score: 0,
       message: "Guess a number",
     )}
  end

  def render(assigns) do
    ~L"""
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
      It's <%= time() %>
    </h2>
    <h2>
      <%= for n <- 1..10 do %>
        <a href="#" phx-click="guess" phx-value-number="<%= n %>"><%= n %></a>
      <% end %>
      <h1 class="text-red-500 text-5xl font-bold text-center">Tailwind CSS</h1>
    </h2>
    """
  end

  def time() do
    DateTime.utc_now() |> to_string
  end

  def handle_event("guess", %{"number" => guess} = _data, socket) do
    message = "Your guess: #{guess}. Wrong. Guess again. "
    score = socket.assigns.score - 1

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score
      )
    }
  end
end
