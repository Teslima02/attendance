defmodule Attendance.Errors.GraphqlErrors do
  @moduledoc """
  This allows resolver functions to be much simpler, because this module will
  help with transforming errors to support garaphql errors.

  ## Example

      # Resolver function
      def get(%{id: id}, _context) do
        case ecto_operation(id) do
          {:ok, user} ->
            {:ok, %{user: user}}
          {:error, changeset} ->
            {:error,
            message: "An error occured while registering the user.",
            details: Attendance.Middleware.HandleErrors.transform_errors(changeset)}
        end
      end
  """

  def transform_errors(%{__struct__: Ecto.Changeset} = changeset) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &format_error/1), type: :changeset}
  end

  def format_error({msg, opts}) do
    msg =
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)

    %{
      type: opts[:validation] || :unique,
      message: msg
    }
  end
end
