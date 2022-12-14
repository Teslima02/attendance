defmodule AttendanceApi.Types.Lecturer do
  use Absinthe.Schema.Notation

  alias Hex.Resolver
  alias AttendanceApi.Resolvers

  @desc "attendance input"
  input_object :lecturer_attendance_input do
    field :semester_id, :string
    field :class_id, :string
    field :program_id, :string
    field :course_id, :string
    field :start_date, :datetime
    field :end_date, :datetime
  end

  @desc "attendance input"
  object :lecturer_attendance do
    field :semester, :semester
    field :class, :class
    field :program, :program
    field :course, :lecturer_courses
    field :start_date, :datetime
    field :end_date, :datetime
    field :active, :boolean
    field :id, :id
  end

  @desc "class object"
  object :class do
    field :id, :id
    field :name, :string
    field :disabled, :boolean
  end

  @desc "course filter input"
  input_object :lecturer_courses_filter_input do
    field :session_id, :string
    field :program_id, :string
    field :class_id, :string
    field :semester_id, :string
  end

  @desc "course object"
  object :lecturer_courses do
    field :id, :id
    field :code, :string
    field :description, :string
    field :name, :string
  end

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

  object :lecturer_attendance_mutation do

    @desc """
    Lecturer attendance.
    """
    field :lecturer_attendance, :lecturer_attendance do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      arg(:input, non_null(:lecturer_attendance_input))
      resolve(&Resolvers.Lecturer.create_lecturer_attendance/2)
    end
  end

  object :lecturer_queries do

    @desc """
    Get list of lecturers.
    """
    field :list_lecturers, list_of(:lecturer) do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.list_lecturers/2)
    end

    @desc """
    Current lecturer details
    """
    field :current_lecturer, :lecturer do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.get_current_lecturer/2)
    end

    @desc """
    Get lecturer courses
    """
    field :lecturer_courses, list_of(:lecturer_courses) do
      arg(:input, :lecturer_courses_filter_input)
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.get_lecturer_courses/2)
    end
  end
end
