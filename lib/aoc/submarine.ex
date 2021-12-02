defmodule AOC.Submarine do

  def get_position() do
    "data/2021-day2.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> follow_path({0,0})
    |> (&(elem(&1, 0) * elem(&1, 1))).()
  end

  defp follow_path([], pos), do: pos
  defp follow_path([val | rest], pos), do: follow_path(rest, update_pos(val, pos))

  defp update_pos(<<"forward ", m::binary>>, {v, h}), do: {v, h + String.to_integer(m)}
  defp update_pos(<<"down ", m::binary>>, {v, h}), do: {v + String.to_integer(m), h}
  defp update_pos(<<"up ", m::binary>>, {v, h}), do: {v - String.to_integer(m), h}

  def get_position_with_aim() do
    "data/2021-day2-test.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> follow_aim_path({0, 0, 0})
    |> (&(elem(&1, 0) * elem(&1, 1))).()
  end

  defp follow_aim_path([], pos), do: pos
  defp follow_aim_path([val | rest], pos), do: follow_aim_path(rest, update_aim_pos(val, pos))

  defp update_aim_pos(<<"forward ", m::binary>>, {v, h, a}) do
    {v + (String.to_integer(m) * a), h + String.to_integer(m), a}
  end

  defp update_aim_pos(<<"down ", m::binary>>, {v, h, a}) do
    {v, h, a + String.to_integer(m)}
  end
  defp update_aim_pos(<<"up ", m::binary>>, {v, h, a}) do
    {v, h, a - String.to_integer(m)}
  end

  def count_depth_increases() do
    "data/2021-day1.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> count_inc(0)
  end


  def count_depth_increases_with_sliding_window() do
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
