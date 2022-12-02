defmodule AOCTest do
  use ExUnit.Case

  {:ok, modules} = :application.get_key(:aoc, :modules)

  for mod <- modules |> Enum.filter(&Extensions.module_has_prefix(&1, "Aoc2022")) do
    describe "#{mod}" do
      for {{fun_name, input, output}, index} <- mod.examples |> Enum.with_index() do
        {fun, _} = Code.eval_string("&#{mod}.#{fun_name}/1")

        case output do
          :noop ->
            :noop

          :research ->
            Extensions.pretty_print_result(fun, input, index)

          _ ->
            test "Example #{index}, #{inspect(fun)}, #{input} -> #{output}" do
              assert unquote(fun).(unquote(input)) === unquote(output)
            end
        end
      end
    end
  end
end
