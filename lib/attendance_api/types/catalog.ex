defmodule AttendanceApi.Types.Catalog do
  use Absinthe.Schema.Notation

  alias AttendanceApi.Resolvers

  @desc "Session object"
  object :session do
    field :id, non_null(:string)
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :disabled, :boolean
  end

  @desc "Semester object"
  object :semester do
    field :id, non_null(:string)
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :disabled, :boolean
  end

  @desc "Program type"
  enum :program_type do
    value(:full_time)
    value(:part_time)
  end

  @desc "Semester filter input Object"
  input_object :semester_filter_input do
    field :program_type, :string
  end

  @desc "Program filter input Object"
  input_object :program_filter_input do
    field :name_contains, :string
    field :disabled, :boolean
    field :program_type, :string
    field :session_id, :string
  end

  @desc "Program input object"
  input_object :get_program_input do
    field :page, :integer, default_value: 1
    field :page_size, :integer, default_value: 15
    field :sort_field, :string, default_value: "inserted_at"
    field :sort_direction, :string, default_value: "desc"
    field :program, :program_filter_input, default_value: %{}
  end

  @desc "Program object"
  object :program do
    field :id, non_null(:string)
    field :name, :string
    field :disabled, :boolean
    field :program_type, :program_type
  end

  @desc "List program object"
  object :list_program do
    field :programs, list_of(:program)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :distance, :integer
    field :sort_field, :string
    field :sort_direction, :string
  end

  @desc "List class Object"
  object :list_class do
    field :classes, list_of(:class)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
    field :distance, :integer
    field :sort_field, :string
    field :sort_direction, :string
  end

  @desc "class input"
  input_object :class_filter_input do
    field :program_id, :string
    field :session_id, :string
    field :name, :string
  end

  @desc "get class input"
  input_object :get_class_input do
    field :page, :integer, default_value: 1
    field :page_size, :integer, default_value: 15
    field :sort_field, :string, default_value: "inserted_at"
    field :sort_direction, :string, default_value: "desc"
    field :class, :class_filter_input, default_value: %{}
  end

  object :session_queries do

    @desc """
    Get current session.
    """
    field :get_current_session, :session do
      resolve(&Resolvers.Catalog.current_session/2)
    end
  end

  object :semester_queries do

    @desc """
    Get current semester.
    """
    field :get_current_semester, :semester do
      arg(:input, non_null(:semester_filter_input))
      resolve(&Resolvers.Catalog.get_current_semester/2)
    end
  end

  object :program_queries do

    @desc """
    Get list of programs.
    """
    field :list_programs, :list_program do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      arg(:input, :get_program_input)
      resolve(&Resolvers.Catalog.list_programs/2)
    end

    @desc """
    Get list of classes.
    """
    field :list_classes, :list_class do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      arg(:input, :get_class_input)
      resolve(&Resolvers.Catalog.list_classes/2)
    end
  end
end
