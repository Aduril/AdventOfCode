defmodule Extensions do
  @moduledoc """
    This is a module for generic tasks thart occur more than once, e.g. read a file line by line.
  """

  @doc """
  Check if the module has a specific prefix
  """
  def module_has_prefix(module, prefix) do
    module
    |> Atom.to_string()
    |> String.replace_leading("Elixir.", "")
    |> String.starts_with?(prefix)
  end

  def file_to_line_list(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end

  defmacro __using__(_opts) do
    quote do
      import Extensions

      def examples, do: @examples
    end
  end
end
