defmodule Attendance.StudentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Students` context.
  """

  def unique_student_email, do: "student#{System.unique_integer()}@example.com"
  def valid_student_password, do: "hello world!"

  def valid_student_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_student_email(),
      password: valid_student_password()
    })
  end

  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> valid_student_attributes()
      |> Attendance.Students.register_student()

    student
  end

  def extract_student_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
