defmodule AOCTest do
  use ExUnit.Case

  {:ok, modules} = :application.get_key(:aoc, :modules)

  for mod <- modules |> Enum.filter(&Extensions.module_has_prefix(&1, "Aoc2022")) do
    describe "#{mod}" do
      for {{fun, input, output}, index} <- mod.examples |> Enum.with_index() do
        test "Example #{index}, #{inspect(fun)}, #{input} -> #{output}" do
          assert unquote(fun).(unquote(input)) === unquote(output)
        end
      end
    end
  end
end
