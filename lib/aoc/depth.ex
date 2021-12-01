defmodule AOC.Depth do

  def count_increases() do
    "data/2021-day1.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> count_inc(0)
  end


  def count_sliding_window_increases() do
    "data/2021-day1.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> get_sliding_windows()
    |> count_inc(0)
  end

  defp get_sliding_windows([_ | [_ | []]]), do: []
  defp get_sliding_windows([a | [b | [c | _]] = rest]), do: [a+b+c|get_sliding_windows(rest)]

  defp count_inc([_ | []], counter), do: counter
  defp count_inc([v1 | [v2 | _] = rest], counter), do: count_inc(rest, inc(counter, v1, v2))

  defp inc(counter, v1, v2), do: if v2 > v1, do: counter + 1, else: counter

end
