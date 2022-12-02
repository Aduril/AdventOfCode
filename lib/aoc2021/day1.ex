defmodule Aoc2021.Day1 do
  @examples [
    {:first_task, "data/2021-day1-test.txt", 7},
    {:first_task, "data/2021-day1.txt", 1477},
    {:second_task, "data/2021-day1-test.txt", 5},
    {:second_task, "data/2021-day1.txt", 1523}
  ]

  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&String.to_integer/1)
    |> count_inc(0)
  end

  def second_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&String.to_integer/1)
    |> get_sliding_windows()
    |> count_inc(0)
  end

  defp get_sliding_windows([_ | [_ | []]]), do: []
  defp get_sliding_windows([a | [b | [c | _]] = rst]), do: [a + b + c | get_sliding_windows(rst)]

  defp count_inc([_ | []], counter), do: counter
  defp count_inc([v1 | [v2 | _] = rest], counter), do: count_inc(rest, inc(counter, v1, v2))

  defp inc(counter, v1, v2), do: if(v2 > v1, do: counter + 1, else: counter)
end
