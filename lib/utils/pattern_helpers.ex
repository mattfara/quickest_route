defmodule PatternHelpers do
  @moduledoc """
  Macros and functions that extend use of pattern matching to new contexts
  """

  @doc """
  Filter a value out of data using a pattern with one variable. Returns a default value
  if no match. Raises if pattern contains no variables or more than one variable.

  ## Examples

  iex> "$3.45" |> PatternHelpers.pattern_filter("$" <> money) |> String.to_float()
  3.45

  iex> {1,2,3} |> PatternHelpers.pattern_filter({1,_,a})
  3

  iex> %{a: 1, b: 2} |> PatternHelpers.pattern_filter(%{a: 9, b: b})
  nil

  iex> %{a: 1, b: 2} |> PatternHelpers.pattern_filter(%{a: 9, b: b}, "???")
  "???"
  """
  defmacro pattern_filter(value, pattern, default \\ nil) do
    atom = parse_ast_for_pattern_variable_atom(pattern)

    quote do
      try do
        unquote(pattern) = unquote(value)

        Keyword.get(binding(), unquote(atom))
      rescue
        MatchError -> unquote(default)
      end
    end
  end

  @doc """
  See `pattern_filter/3`. Raises if no match.

  ## Examples

  iex> {1,2,3} |> PatternHelpers.pattern_filter!({9,_,b})
  ** (MatchError) no match of right hand side value: {1, 2, 3}

  Note that a try/rescue is used here only to limit variable scope;
  all errors are re-raised.
  """
  defmacro pattern_filter!(value, pattern) do
    atom = parse_ast_for_pattern_variable_atom(pattern)

    quote do
      try do
        unquote(pattern) = unquote(value)

        Keyword.get(binding(), unquote(atom))
      rescue
        e -> reraise e, __STACKTRACE__
      end
    end
  end

  defp parse_ast_for_pattern_variable_atom(ast) do
    {_, variable_atoms} = Macro.prewalk(ast, [], &extract_atom/2)

    get_pattern_atom(variable_atoms)
  end

  # The AST produced for patterns is different when running in iex, so we can match against two ASTs

  defp extract_atom({atom, [line: _], nil} = node, acc), do: skip_underscored(node, atom, acc)

  defp extract_atom({atom, [if_undefined: :apply, line: _], nil} = node, acc),
    do: skip_underscored(node, atom, acc)

  defp extract_atom(node, acc), do: {node, acc}

  defp skip_underscored(node, atom, acc) do
    atom
    |> Atom.to_string()
    |> String.starts_with?("_")
    |> if do
      {node, acc}
    else
      {node, [atom | acc]}
    end
  end

  defp get_pattern_atom([atom]), do: atom

  defp get_pattern_atom(atoms),
    do:
      raise(
        ArgumentError,
        """

        Filter pattern must have exactly one variable, e.g., %{a: 1, b: b},

        but never %{a: a, b: b} or %{a: 1, b: 2} and you supplied a pattern

        with these variables: #{inspect(atoms)}

        """
      )
end
