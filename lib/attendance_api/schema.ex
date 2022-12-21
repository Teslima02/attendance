defmodule AttendanceApi.Schema do
  use Absinthe.Schema

  alias AttendanceApi.Types

  import_types(Absinthe.Type.Custom)
  import_types(Types.Lecturer)
  import_types(Types.Catalog)

  mutation do
    import_fields(:lecturer_mutation)
  end

  query do
    import_fields(:lecturer_queries)
    import_fields(:program_queries)
    import_fields(:session_queries)
  end
end
