defmodule Attendance.Guardian do
  use Guardian, otp_app: :attendance

  alias Attendance.Lecturers.Lecturer
  alias Attendance.Lecturers

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    lecturer = Lecturers.get_lecturer!(id)
    {:ok,  lecturer}
  end
  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
