defmodule AOC.Submarine do
  def check_life_support() do
    "data/2021-day3.txt"
    |> file_to_line_list()
    |> get_life_support_rate()
  end

  defp get_life_support_rate(list) do
    oxy = list |> find_binary_oxygen_value(0) |> parse_binary()
    co2 = list |> find_binary_co2_value(0) |> parse_binary()
    oxy * co2
  end

  defp find_binary_oxygen_value([value], _), do: value
  defp find_binary_oxygen_value(list, pos) do
    { zeros, ones } = count_zeros_and_ones_at_pos(list, pos)
    to_filter = if zeros > ones, do: "0", else: "1"

    list
    |> Enum.filter(fn str -> String.at(str, pos) == to_filter end)
    |> find_binary_oxygen_value(pos + 1)
  end


  defp find_binary_co2_value([value], _), do: value
  defp find_binary_co2_value(list, pos) do
    { zeros, ones } = count_zeros_and_ones_at_pos(list, pos)
    to_filter = if zeros > ones, do: "1", else: "0"

    list
    |> Enum.filter(fn str -> String.at(str, pos) == to_filter end)
    |> find_binary_co2_value(pos + 1)
  end

  defp count_zeros_and_ones_at_pos(list, pos) do
    zeros = Enum.count(list, fn str -> String.at(str, pos) == "0" end)
    ones = Enum.count(list, fn str -> String.at(str, pos) == "1" end)
    {zeros, ones}
  end



  def check_power_consumption() do
    "data/2021-day3.txt"
    |> file_to_line_list()
    |> Enum.reject(&(&1 == ""))
    |> get_power_consumption_rate()
  end

  defp get_power_consumption_rate(list) do
    counter_map = count_per_pos(list, %{})
    gamma = get_gamma_from_counter(counter_map)
    epsilon = get_epsilon_from_counter(counter_map)
    gamma * epsilon
  end

  defp count_per_pos([], map), do: map
  defp count_per_pos([val | rest], map), do: count_per_pos(rest, freqirate(val, map, 0))

  defp freqirate(<<val::binary-size(1)>>, map, counter), do: freq(map, val, counter)
  defp freqirate(<<v::binary-size(1), r::binary>>, m, c), do: freqirate(r, freq(m, v, c), c + 1)

  defp freq(map, "0", counter), do: Map.update(map, "#{counter}", -1, &(&1 - 1))
  defp freq(map, "1", counter), do: Map.update(map, "#{counter}", 1, &(&1 + 1))

  defp get_gamma_from_counter(counter_map) do
    counter_map
    |> Enum.map(fn {key, val} -> {String.to_integer(key), map_gamma_value(val)} end)
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.join()
    |> parse_binary()
  end

  defp get_epsilon_from_counter(counter_map) do
    counter_map
    |> Enum.map(fn {key, val} -> {String.to_integer(key), map_epsilon_value(val)} end)
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.join()
    |> parse_binary()
  end

  defp parse_binary(str), do: str |> Integer.parse(2) |> elem(0)

  defp map_gamma_value(val) when val < 0, do: "0"
  defp map_gamma_value(val) when val > 0, do: "1"
  defp map_gamma_value(_val), do: raise "Strange value!"


  defp map_epsilon_value(val) when val > 0, do: "0"
  defp map_epsilon_value(val) when val < 0, do: "1"
  defp map_epsilon_value(_val), do: raise "Strange value!"

  def get_position() do
    "data/2021-day2.txt"
    |> file_to_line_list()
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
    |> file_to_line_list()
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
    |> file_to_line_list()
    |> Enum.map(&String.to_integer/1)
    |> count_inc(0)
  end


  def count_depth_increases_with_sliding_window() do
    "data/2021-day1.txt"
    |> file_to_line_list()
    |> Enum.map(&String.to_integer/1)
    |> get_sliding_windows()
    |> count_inc(0)
  end

  defp get_sliding_windows([_ | [_ | []]]), do: []
  defp get_sliding_windows([a | [b | [c | _]] = rest]), do: [a+b+c|get_sliding_windows(rest)]

  defp count_inc([_ | []], counter), do: counter
  defp count_inc([v1 | [v2 | _] = rest], counter), do: count_inc(rest, inc(counter, v1, v2))

  defp inc(counter, v1, v2), do: if v2 > v1, do: counter + 1, else: counter

  # generic helpers


  defp file_to_line_list(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end
end
