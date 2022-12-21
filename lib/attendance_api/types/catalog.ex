defmodule AttendanceApi.Types.Catalog do
  use Absinthe.Schema.Notation

  alias Hex.Resolver
  alias AttendanceApi.Resolvers

  @desc "Session object"
  object :session do
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

  @desc "Program filter input Object"
  input_object :program_filter_input do
    field :name_contains, :string
    field :disabled, :boolean
    field :program_type, :string
    # field :program_type, :program_type
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

  # object :lecturer_mutation do

  #   @desc """
  #   Lecturer login.
  #   """
  #   field :lecturer_login, :lecturer_login_object do
  #     arg(:input, non_null(:lecturer_login))
  #     resolve(&Resolvers.Lecturer.lecturer_login/2)
  #   end
  # end

  object :session_queries do

    @desc """
    Get current session.
    """
    field :get_current_session, :session do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Catalog.current_session/2)
    end

    # @desc """
    # Get a program.
    # """
    # field :list_lecturers, list_of(:lecturer) do
    #   middleware(AttendanceApi.Middleware.LecturerAuth)
    #   resolve(&Resolvers.Catalog.list_programs/2)
    # end
  end

  object :program_queries do

    @desc """
    Get list of programs.
    """
    field :list_programs, list_of(:list_program) do
      arg(:input, non_null(:get_program_input))
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Catalog.list_programs/2)
    end

    # @desc """
    # Get a program.
    # """
    # field :list_lecturers, list_of(:lecturer) do
    #   middleware(AttendanceApi.Middleware.LecturerAuth)
    #   resolve(&Resolvers.Catalog.list_programs/2)
    # end
  end
end
