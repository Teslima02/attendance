defmodule AttendanceApi.Topics.Topics do
  @lecturer_open_attendance "LECTURER_OPEN_ATTENDANCE"
  @lecturer_send_notification "LECTURER_SEND_NOTIFICATION"

  def lecturer_open_attendance, do: @lecturer_open_attendance
  def lecturer_send_notification, do: @lecturer_send_notification
end
