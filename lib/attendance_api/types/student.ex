defmodule AttendanceApi.Types.Student do
  use Absinthe.Schema.Notation

  alias Hex.Resolver
  alias AttendanceApi.Resolvers

  # @desc "attendance input"
  # input_object :lecturer_attendance_input do
  #   field :semester_id, :string
  #   field :class_id, :string
  #   field :program_id, :string
  #   field :course_id, :string
  #   field :start_date, :datetime
  #   field :end_date, :datetime
  # end

  # @desc "attendance input"
  # object :lecturer_attendance do
  #   field :semester, :semester
  #   field :class, :class
  #   field :program, :program
  #   field :course, :lecturer_courses
  #   field :start_date, :datetime
  #   field :end_date, :datetime
  #   field :active, :boolean
  #   field :id, :id
  # end

  # @desc "class object"
  # object :class do
  #   field :id, :id
  #   field :name, :string
  #   field :disabled, :boolean
  # end

  @desc "course object"
  object :student_courses do
    field :id, :id
    field :code, :string
    field :description, :string
    field :name, :string
  end

  @desc "Student login input"
  input_object :student_login_input do
    field :matric_number, non_null(:string)
    field :password, non_null(:string)
  end

  @desc "Student login object"
  object :student_login_object do
    field :student, :student
    field :token, :string
  end

  @desc "Student object"
  object :student do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :matric_number, :string
  end

  object :student_mutation do

    @desc """
    Student login.
    """
    field :student_login, :student_login_object do
      arg(:input, non_null(:student_login_input))
      resolve(&Resolvers.Student.student_login/2)
    end
  end

  # object :lecturer_attendance_mutation do

  #   @desc """
  #   Lecturer attendance.
  #   """
  #   field :lecturer_attendance, :lecturer_attendance do
  #     middleware(AttendanceApi.Middleware.LecturerAuth)
  #     arg(:input, non_null(:lecturer_attendance_input))
  #     resolve(&Resolvers.Lecturer.create_lecturer_attendance/2)
  #   end
  # end

  object :student_queries do

  #   @desc """
  #   Get list of lecturers.
  #   """
  #   field :list_lecturers, list_of(:lecturer) do
  #     middleware(AttendanceApi.Middleware.LecturerAuth)
  #     resolve(&Resolvers.Lecturer.list_lecturers/2)
  #   end

    @desc """
    Current student details
    """
    field :current_student, :student do
      middleware(AttendanceApi.Middleware.StudentAuth)
      resolve(&Resolvers.Student.get_current_student/2)
    end

    @desc """
    Get student courses
    """
    field :student_courses, list_of(:student_courses) do
      middleware(AttendanceApi.Middleware.StudentAuth)
      resolve(&Resolvers.Student.get_student_courses/2)
    end
  end
end
