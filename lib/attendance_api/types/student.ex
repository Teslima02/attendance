defmodule AttendanceApi.Types.Student do
  use Absinthe.Schema.Notation

  alias AttendanceApi.Resolvers

  @desc "student mark attendance input"
  input_object :student_mark_attendance_input do
    field :attendance_time, :datetime
    field :course_id, :string
    field :lecturer_attendance_id, :string
  end

  @desc "student attendance object"
  object :student_attendance do
    field :id, :id
    field :status, :boolean
    field :attendance_time, :datetime
  end

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

    @desc """
    Student mark attendance.
    """
    field :student_mark_attendance, :student_attendance do
      middleware(AttendanceApi.Middleware.StudentAuth)
      arg(:input, non_null(:student_mark_attendance_input))
      resolve(&Resolvers.Student.mark_attendance/2)
    end
  end

  object :student_queries do
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
