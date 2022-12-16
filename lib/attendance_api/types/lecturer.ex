defmodule AttendanceApi.Types.Lecturer do
  use Absinthe.Schema.Notation

  alias AttendanceApi.Resolvers

  @desc "Lecturer login input"
  input_object :lecturer_login do
    field :matric_number, non_null(:string)
    field :password, non_null(:string)
  end

  @desc "Lecturer login object"
  object :lecturer_login_object do
    field :lecturer, :lecturer
    field :token, :string
  end

  @desc "List lecturers object"
  object :lecturer do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :matric_number, :string
  end

  object :lecturer_mutation do

    @desc """
    Lecturer login.
    """
    field :lecturer_login, :lecturer_login_object do
      arg(:input, non_null(:lecturer_login))
      resolve(&Resolvers.Lecturer.lecturer_login/2)
    end
  end

  object :lecturer_queries do

    @desc """
    Get list of lecturers.
    """
    field :list_lecturers, list_of(:lecturer) do
      resolve(&Resolvers.Lecturer.list_lecturers/2)
    end
  end
end