defmodule AOC.Submarine do
  def line_up_crabs() do
    "data/2021-day7-test.txt"
    |> file_to_line_list()
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> find_minimal_distance()
  end

  defp find_minimal_distance(points) do
    min = Enum.min(points)
    max = Enum.max(points)
    range = min..max

    range
    |> Enum.map(&get_fuel_consume(&1, points, 0))
    |> IO.inspect(label: "THIS_IS_FOR_DEBUG_REASONS: consumes")
    |> Enum.min_by(fn {_target, consume} -> consume end)
  end

  defp get_fuel_consume(target, [], consume), do: {target, consume}
  # defp get_fuel_consume(t, [p | points], c), do: get_fuel_consume(t, points, c + abs(t - p))
  defp get_fuel_consume(t, [p | ps], c), do: get_fuel_consume(t, ps, calc_fuel_consume(t, p, c))

  defp calc_fuel_consume(target, point, consume) do
    1
    |> Range.new(abs(target - point))
    |> Enum.sum()
    |> Kernel.+(consume)
  end

  def estimate_lantern_fishes() do
    "data/2021-day6.txt"
    |> file_to_line_list()
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
    |> run_lantern_fish_simulation(256)
    |> count_fishes()
  end

  defp count_fishes(fish_map) do
    fish_map
    |> Map.values()
    |> Enum.sum()
  end

  defp run_lantern_fish_simulation(fishes, 0), do: fishes
  defp run_lantern_fish_simulation(fishes, days), do: run_a_simulation_day(fishes, days)

  defp run_a_simulation_day(fishes, days) do
    fishes
    |> update_population()
    |> run_lantern_fish_simulation(days - 1)
  end

  defp update_population(fishes) do
    fishes
    |> Enum.map(fn {day, no} -> {calc_day(day), no} end)
    |> (&[{8, Map.get(fishes, 0, 0)} | &1]).()
    |> create_new_fish_map(%{})
  end

  defp create_new_fish_map([], map), do: map
  defp create_new_fish_map([f | fs], map), do: create_new_fish_map(fs, update_fish_map(map, f))

  defp update_fish_map(map, {day, no}), do: Map.update(map, day, no, fn v -> v + no end)

  defp calc_day(0), do: 6
  defp calc_day(day), do: day - 1

  def navigate_all_pipes() do
    "data/2021-day5.txt"
    |> file_to_line_list()
    |> get_directions()
    |> generate_piped_fields()
    |> print_fields()
    |> calculate_number_of_steamy_fields()
  end

  def navigate_straight_pipes() do
    "data/2021-day5.txt"
    |> file_to_line_list()
    |> get_directions()
    |> remove_none_straight_directions()
    |> generate_piped_fields()
    |> print_fields()
    |> calculate_number_of_steamy_fields()
  end

  defp calculate_number_of_steamy_fields(fields) do
    fields
    |> Enum.frequencies()
    |> Enum.filter(fn {{_x, _y}, v} -> v > 1 end)
    |> length()
  end

  defp print_fields(piped_fields) do
    max_x = piped_fields |> Enum.max_by(fn {x, _y} -> x end) |> elem(0)
    max_y = piped_fields |> Enum.max_by(fn {_x, y} -> y end) |> elem(1)

    all_fields =
      for x <- 0..max_x, y <- 0..max_y do
        {x, y, Enum.count(piped_fields, fn {fx, fy} -> fx == x and fy == y end)}
      end

    file = File.stream!("pipe_map.txt")

    all_fields
    |> sort_fields()
    |> Stream.into(file)
    |> Stream.run()

    piped_fields
  end

  defp sort_fields(fields) do
    fields
    |> Enum.group_by(fn {_x, y, _v} -> y end)
    |> Enum.map(fn {y, field} -> {y, sort_fields_by_x(field)} end)
    |> Enum.sort_by(fn {y, _} -> y end)
    |> Enum.map(fn {_, v} -> Enum.join(v) end)
  end

  defp sort_fields_by_x(field) do
    field
    |> Enum.group_by(fn {x, _, _} -> x end)
    |> Enum.map(fn {x, field} -> {x, field} end)
    |> Enum.sort_by(fn {y, _} -> y end)
    |> Enum.map(fn {_, [{_, _, v}]} -> v end)
  end

  defp generate_piped_fields([]), do: []

  defp generate_piped_fields([direction | directions]) do
    {x1, y1} = direction.from
    {x2, y2} = direction.to
    get_used_coordinates(x1, y1, x2, y2) ++ generate_piped_fields(directions)
  end

  defp get_used_coordinates(x1, y1, x2, y2) do
    x_add = x1 |> Kernel.-(x2) |> get_move()
    y_add = y1 |> Kernel.-(y2) |> get_move()

    if x_add == 0 and y_add == 0 do
      [{x1, y1}]
    else
      [{x1, y1} | get_used_coordinates(x1 + x_add, y1 + y_add, x2, y2)]
    end
  end

  defp get_move(0), do: 0
  defp get_move(diff) when diff > 0, do: -1
  defp get_move(diff) when diff < 0, do: 1

  defp remove_none_straight_directions([]), do: []

  defp remove_none_straight_directions([direction | directions]) do
    {x1, y1} = direction.from
    {x2, y2} = direction.to

    if x1 == x2 or y1 == y2 do
      [direction | remove_none_straight_directions(directions)]
    else
      remove_none_straight_directions(directions)
    end
  end

  defp get_directions([]), do: []
  defp get_directions([entry | list]), do: [get_direction(entry) | get_directions(list)]

  defp get_direction(entry) do
    entry
    |> String.split(~r{((->)|,|\s)})
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> map_to_direction()
  end

  defp map_to_direction([x1, y1, x2, y2]), do: %{from: {x1, y1}, to: {x2, y2}}

  def play_bingo_board_to_lose() do
    "data/2021-day4.txt"
    |> file_to_line_list()
    |> find_worst_board()
    |> calculate_result()
  end

  def play_bingo_board_to_win() do
    "data/2021-day4-test.txt"
    |> file_to_line_list()
    |> find_best_board()
    |> calculate_result()
  end

  defp find_worst_board([moves | boards]) do
    moves = String.split(moves, ",")
    boards = boards |> build_boards()
    run_board_until_last_wins(boards, moves)
  end

  defp run_board_until_last_wins(boards, moves) do
    {winners, move, boards, moves} = play_game(boards, moves)

    cond do
      length(moves) == 0 -> {winners, move, boards, moves}
      Enum.all?(boards, fn f -> f.board in winners end) -> {winners, move, boards, moves}
      true -> boards |> Enum.reject(&(&1.board in winners)) |> run_board_until_last_wins(moves)
    end
  end

  defp find_best_board([moves | boards]) do
    moves = String.split(moves, ",")

    boards
    |> build_boards()
    |> play_game(moves)
  end

  defp play_game({[], move, boards}, []), do: {nil, move, boards, []}
  defp play_game({[], _, boards}, moves), do: play_game(boards, moves)
  defp play_game({winners, move, boards}, moves), do: {winners, move, boards, moves}
  defp play_game(boards, [move | moves]), do: play_game(play_move(boards, move), moves)

  defp play_move(boards, move) do
    boards
    |> Enum.map(&mark_fields(&1, move))
    |> check_for_winner(move)
  end

  defp calculate_result({[winner | _], move, fields, _moves}) do
    fields
    |> Enum.filter(fn f -> f.board == winner end)
    |> Enum.filter(fn f -> f.marked == false end)
    |> Enum.map(fn f -> String.to_integer(f.value) end)
    |> Enum.sum()
    |> Kernel.*(String.to_integer(move))
  end

  defp check_for_winner(fields, move) do
    x_columns =
      fields
      |> Enum.filter(fn f -> f.marked == true end)
      |> Enum.group_by(fn f -> "#{f.board}#{f.x}" end)
      |> Enum.map(fn {k, v} -> {k, v} end)

    y_columns =
      fields
      |> Enum.filter(fn f -> f.marked == true end)
      |> Enum.group_by(fn f -> "#{f.board}#{f.y}" end)
      |> Enum.map(fn {k, v} -> {k, v} end)

    winners =
      x_columns
      |> Kernel.++(y_columns)
      |> Enum.map(fn {_, val} -> get_winner_board(val) end)
      |> Enum.reject(fn b -> is_nil(b) end)

    {winners, move, fields}
  end

  defp get_winner_board(list) when length(list) < 5, do: nil
  defp get_winner_board([f | _] = list) when length(list) == 5, do: f.board

  defp mark_fields(field, move) do
    Map.update(field, :marked, false, fn v -> v || field.value == move end)
  end

  defp build_boards(boards) do
    boards
    |> Enum.map(fn board -> board |> String.split(" ") |> Enum.reject(&(&1 == "")) end)
    |> Enum.chunk_every(5)
    |> Enum.with_index()
    |> Enum.map(&build_board/1)
    |> List.flatten()
  end

  defp build_board({lines, index}), do: build_lines(lines, index, 0)

  defp build_lines([], _, _), do: []
  defp build_lines([l | ls], b, y), do: [build_line(l, b, y, 0) | build_lines(ls, b, y + 1)]

  defp build_line([], _, _, _), do: []
  defp build_line([f | fs], b, y, x), do: [build_field(f, b, y, x) | build_line(fs, b, y, x + 1)]

  defp build_field(val, board, y, x), do: %{value: val, y: y, x: x, board: board, marked: false}

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
    {zeros, ones} = count_zeros_and_ones_at_pos(list, pos)
    to_filter = if zeros > ones, do: "0", else: "1"

    list
    |> Enum.filter(fn str -> String.at(str, pos) == to_filter end)
    |> find_binary_oxygen_value(pos + 1)
  end

  defp find_binary_co2_value([value], _), do: value

  defp find_binary_co2_value(list, pos) do
    {zeros, ones} = count_zeros_and_ones_at_pos(list, pos)
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
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
    |> parse_binary()
  end

  defp get_epsilon_from_counter(counter_map) do
    counter_map
    |> Enum.map(fn {key, val} -> {String.to_integer(key), map_epsilon_value(val)} end)
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
    |> parse_binary()
  end

  defp parse_binary(str), do: str |> Integer.parse(2) |> elem(0)

  defp map_gamma_value(val) when val < 0, do: "0"
  defp map_gamma_value(val) when val > 0, do: "1"
  defp map_gamma_value(_val), do: raise("Strange value!")

  defp map_epsilon_value(val) when val > 0, do: "0"
  defp map_epsilon_value(val) when val < 0, do: "1"
  defp map_epsilon_value(_val), do: raise("Strange value!")

  def get_position() do
    "data/2021-day2.txt"
    |> file_to_line_list()
    |> follow_path({0, 0})
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
    {v + String.to_integer(m) * a, h + String.to_integer(m), a}
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

  defp get_sliding_windows([a | [b | [c | _]] = rest]),
    do: [a + b + c | get_sliding_windows(rest)]

  defp count_inc([_ | []], counter), do: counter
  defp count_inc([v1 | [v2 | _] = rest], counter), do: count_inc(rest, inc(counter, v1, v2))

  defp inc(counter, v1, v2), do: if(v2 > v1, do: counter + 1, else: counter)

  # generic helpers

  defp file_to_line_list(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end
end
