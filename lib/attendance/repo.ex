defmodule Attendance.Repo do
  use Ecto.Repo,
    otp_app: :attendance,
    adapter: Ecto.Adapters.Postgres
end
