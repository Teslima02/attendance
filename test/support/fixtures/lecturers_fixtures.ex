defmodule Attendance.LecturersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Lecturers` context.
  """

  def unique_lecturer_email, do: "lecturer#{System.unique_integer()}@example.com"
  def valid_lecturer_password, do: "hello world!"

  def valid_lecturer_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_lecturer_email(),
      password: valid_lecturer_password()
    })
  end

  def lecturer_fixture(attrs \\ %{}) do
    {:ok, lecturer} =
      attrs
      |> valid_lecturer_attributes()
      |> Attendance.Lecturers.register_lecturer()

    lecturer
  end

  def extract_lecturer_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
