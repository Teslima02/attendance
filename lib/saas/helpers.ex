defmodule Saas.Helpers do
  @moduledoc """
  Provides helper functions for Saas-generated code.
  """

  @doc """
  Determines how the query for an index action should be sorted.

  Relies on the `"sort_field"` and `"sort_direction"` parameters to be passed.
  By default, it sorts by `:id` in ascending order.

  ## Examples

      iex> sort(%{"sort_field" => "name", "sort_direction" => "desc"})
      {:desc, :name}

      iex> sort(%{})
      {:asc, :id}

  In a query pipeline, use in conjunction with `Ecto.Query.order_by/3`:

      order_by(query, ^sort(params))

  """
  def sort(params)

  def sort(%{sort_field: field, sort_direction: direction}) do
    {String.to_atom(direction), String.to_atom(field)}
  end

  def sort(%{"sort_field" => field, "sort_direction" => direction}) do
    {String.to_atom(direction), String.to_atom(field)}
  end

  def sort(_other) do
    {:asc, :id}
  end

  @doc """
  Paginates a given `Ecto.Queryable` using Scrivener.

  This is a very thin wrapper around `Scrivener.paginate/2`, so see [the Scrivener
  Ecto documentation](https://github.com/drewolson/scrivener_ecto) for more details.

  ## Parameters

  - `query`: An `Ecto.Queryable` to paginate.
  - `repo`: Your Repo module.
  - `params`: Parameters from your `conn`. For example `%{"page" => 1}`.
  - `settings`: A list of settings for Scrivener, including `:page_size`.

  ## Examples

      paginate(query, Repo, params, [page_size: 15])
      # => %Scrivener.Page{...}
  """
  def paginate(query, repo, params, settings \\ [page_size: 10]) do
    Scrivener.paginate(query, Scrivener.Config.new(repo, settings, params))
  end

  @doc """
  convertes the keys in a map to string from atom

  ## Examples

      stringify_map_key(%{email_contains: "info@qaltrak.com"})
      # => %{"email_contains" => "info@qaltrak.com"}
  """
  def stringify_map_key(map \\ %{}) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
