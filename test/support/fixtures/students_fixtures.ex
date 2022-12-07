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

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        disabled: true,
        first_name: "some first_name",
        last_name: "some last_name",
        matric_number: "some matric_number",
        middle_name: "some middle_name"
      })
      |> Attendance.Students.create_student()

    student
  end
end
