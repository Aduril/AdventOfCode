defmodule AOC.Submarine do
  def find_fastest_route() do
    "data/2021-day15.txt"
    |> file_to_line_list()
    |> create_network()
    |> find_shortest_path_from_top_left_to_right_down()
  end

  defp find_shortest_path_from_top_left_to_right_down(network) do
    [{x, y, w, n, _} | rest] = network
    {target_x, target_y, _, _, _} = List.last(network)
    dijkstraize_network(rest, [{x, y, w, n, 0}], {target_x, target_y})
  end

  defp dijkstraize_network(unvisited_nodes, visited_nodes, target) do
    visited_nodes
    |> Enum.min_by(fn {_, _, _, _, t} -> t end)
    |> visit_or_return(unvisited_nodes, visited_nodes, target)
  end

  defp visit_or_return({xc, yc, _, _, tw} = current, unvisited, visited, {xt, yt} = target) do
    if xc == xt and yc == yt, do: tw, else: visit_node(current, unvisited, visited, target)
  end

  defp visit_node(current, unvisited, visited, target) do
    {neighbors, unvisited, visited} = get_network_neighbors(current, unvisited, visited)

    neighbors
    |> Enum.map(&update_neighbor(&1, current))
    |> Kernel.++(visited)
    |> List.delete(current)
    |> (&dijkstraize_network(unvisited, &1, target)).()
  end

  defp update_neighbor({x, y, nw, n, ntw} = _neighbor, {_, _, _, _, ctw} = _current) do
    new_weight = ctw + nw
    if new_weight < ntw, do: {x, y, nw, n, new_weight}, else: {x, y, nw, n, ntw}
  end

  defp get_network_neighbors({_, _, _, neighbors, _}, unvisited_nodes, visited_nodes) do
    find_nodes(neighbors, unvisited_nodes, visited_nodes, [])
  end

  defp find_nodes([], unvisited, visited, result), do: {result, unvisited, visited}

  defp find_nodes([{x, y} | next_nodes], unvisited, visited, result) do
    case Enum.find(visited, fn {xn, yn, _, _, _} -> xn == x and yn == y end) do
      nil -> find_nodes_in_unvisited({x, y}, next_nodes, unvisited, visited, result)
      val -> find_nodes(next_nodes, unvisited, List.delete(visited, val), [val | result])
    end
  end

  defp find_nodes_in_unvisited({x, y}, next_nodes, unvisited, visited, result) do
    case Enum.find(unvisited, fn {xn, yn, _, _, _} -> xn == x and yn == y end) do
      nil -> find_nodes(next_nodes, unvisited, visited, result)
      val -> find_nodes(next_nodes, List.delete(unvisited, val), visited, [val | result])
    end
  end

  defp create_network(lines) do
    y_max = length(lines)

    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, y} -> create_nodes(line, y, y_max) end)
    |> List.flatten()
  end

  defp create_nodes(line, y, y_max) do
    x_max = String.length(line)

    line
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {weight, x} -> create_node(x, y, x_max, y_max, weight) end)
  end

  defp create_node(x, y, x_max, y_max, weight) do
    for xn <- 0..4, yn <- 0..4 do
      xv = x_max * xn + x
      yv = y_max * yn + y

      {xv, yv, get_own_weight(weight, xn, yn), generate_network_neighbors(xv, yv), :infinity}
    end
  end

  defp get_own_weight(weight, xn, yn) do
    case weight + xn + yn do
      v when v < 10 -> v
      v -> rem(v, 9)
    end
  end

  defp generate_network_neighbors(x, y) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.reject(fn {x, y} -> x < 0 or y < 0 end)
  end

  def mix_polymers(times) do
    "data/2021-day14.txt"
    |> file_to_line_list()
    |> get_starting_polymer_and_rules()
    |> mix_polymer(times)
    |> count_letters()
  end

  defp count_letters(polymer) do
    polymer
    |> Map.keys()
    |> Enum.map(fn k -> k |> String.graphemes() |> Enum.map(&{&1, polymer[k]}) end)
    |> List.flatten()
    |> Enum.group_by(fn {l, _v} -> l end, fn {_l, v} -> v end)
    |> Enum.map(fn {_letter, list} -> list |> Enum.sum() |> Kernel./(2) |> round() end)
    |> Enum.sort()
    |> (&(List.last(&1) - List.first(&1))).()
  end

  defp mix_polymer({polymer, rules}, n), do: mix_polymer(polymer, rules, n)

  defp mix_polymer(polymer, _rules, 0), do: polymer
  defp mix_polymer(polymer, rules, n), do: mix_polymer(calc_polymer(polymer, rules), rules, n - 1)

  defp calc_polymer(polymer, rules) do
    polymer
    |> Map.keys()
    |> update_polymer(polymer, rules, %{})
  end

  defp update_polymer([], _polymer, _rules, new_polymer), do: new_polymer

  defp update_polymer([key | keys], polymer, rules, new_polymer) do
    rules
    |> Map.get(key, key)
    |> List.wrap()
    |> Enum.map(fn new_key -> {new_key, polymer[key]} end)
    |> Enum.reduce(new_polymer, fn {nk, no}, poly -> Map.update(poly, nk, no, &(&1 + no)) end)
    |> (&update_polymer(keys, polymer, rules, &1)).()
  end

  defp get_starting_polymer_and_rules([starting_polymer | rules]) do
    rules
    |> Enum.map(&map_rule/1)
    |> Map.new()
    |> (&{get_polymer_map(%{}, starting_polymer), &1}).()
  end

  defp get_polymer_map(map, <<_::binary-size(1)>>), do: map

  defp get_polymer_map(map, <<set::binary-size(2), _::binary>> = polymer) do
    map
    |> Map.update(set, 1, fn x -> x + 1 end)
    |> get_polymer_map(get_next_polymer_step(polymer))
  end

  defp get_next_polymer_step(<<_::binary-size(1), rest::binary>>), do: rest

  defp map_rule(<<from1::binary-size(1), from2::binary-size(1), " -> ", to::binary-size(1)>>) do
    {"#{from1}#{from2}", ["#{from1}#{to}", "#{to}#{from2}"]}
  end

  def fold_paper() do
    "data/2021-day13.txt"
    |> file_to_line_list()
    |> get_dots_and_instructions()
    |> fold_paper()
    |> pretty_print_folded_paper()
    |> length()
  end

  defp pretty_print_folded_paper(dots) do
    " "
    |> List.duplicate(dots |> Enum.max_by(fn {x, _} -> x end) |> elem(0) |> Kernel.+(1))
    |> List.duplicate(dots |> Enum.max_by(fn {_, y} -> y end) |> elem(1) |> Kernel.+(1))
    |> add_dots(dots)
    |> Enum.map(fn list -> Enum.join(list, "") end)
    |> Enum.each(fn line -> IO.puts(line) end)

    dots
  end

  defp add_dots(canvas, []), do: canvas
  defp add_dots(canvas, [dot | dots]), do: canvas |> add_dot(dot) |> add_dots(dots)

  defp add_dot(canvas, {x, y}) do
    List.update_at(canvas, y, fn line -> List.replace_at(line, x, "#") end)
  end

  def fold_paper_once() do
    "data/2021-day13.txt"
    |> file_to_line_list()
    |> get_dots_and_instructions()
    |> (fn {dots, [first_fold | _folds]} -> {dots, [first_fold]} end).()
    |> fold_paper()
    |> length()
  end

  defp fold_paper({dots, folds}) do
    run_folds(dots, folds)
  end

  defp run_folds(dots, []), do: dots
  defp run_folds(dots, [fold | folds]), do: run_folds(run_fold(dots, fold), folds)

  defp run_fold(dots, {axis, position}) do
    dots
    |> pretty_print_folded_paper()
    |> Enum.map(&map_dot_to_new_dot(&1, axis, position))
    |> Enum.uniq()
  end

  defp map_dot_to_new_dot({x, y}, "x", position) do
    case x - position do
      diff when diff < 0 -> {x, y}
      diff -> {x - 2 * diff, y}
    end
  end

  defp map_dot_to_new_dot({x, y}, "y", position) do
    case y - position do
      diff when diff < 0 -> {x, y}
      diff -> {x, y - 2 * diff}
    end
  end

  defp get_dots_and_instructions(line_list) do
    dots =
      line_list
      |> Enum.filter(&String.contains?(&1, ","))
      |> Enum.map(&map_line_to_dot_tuple/1)

    folds =
      line_list
      |> Enum.filter(&String.contains?(&1, "fold along"))
      |> Enum.map(&map_line_to_fold_tuple/1)

    {dots, folds}
  end

  defp map_line_to_dot_tuple(str) do
    str |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end

  defp map_line_to_fold_tuple(str) do
    [axis, position] =
      str
      |> String.trim_leading("fold along ")
      |> String.split("=")

    {axis, String.to_integer(position)}
  end

  def find_distinct_cave_paths_for_multi_visit() do
    "data/2021-day12.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> String.split(line, "-") end)
    |> find_all_paths("task2")
  end

  def find_distinct_cave_paths_for_single_visit() do
    "data/2021-day12.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> String.split(line, "-") end)
    |> find_all_paths("task1")
  end

  defp find_all_paths(connections, task) do
    connections
    |> get_all_caves_from_connections()
    |> find_cave_paths(task)
    |> Enum.filter(fn list -> List.first(list) == "end" end)
    |> Enum.uniq()
    |> length()
  end

  defp find_cave_paths(caves, task), do: find_next_path([{caves, ["start"]}], [], task)

  defp find_next_path([], known_paths, _task), do: known_paths

  defp find_next_path([{caves, [current_cave | _] = path} | cave_path_sets], known_paths, task) do
    caves = add_cave_visit(caves, current_cave)

    caves
    |> Map.get(current_cave)
    |> Map.get(:neighbors)
    |> Enum.filter(fn cave -> allowed_cave?(caves, cave, task) end)
    |> Enum.map(fn cave -> {caves, [cave | path]} end)
    |> Kernel.++(cave_path_sets)
    |> find_next_path([path | known_paths], task)
  end

  defp allowed_cave?(caves, cave, "task1") do
    caves[cave].big_cave? or caves[cave].no_of_visits == 0
  end

  defp allowed_cave?(caves, cave, "task2") do
    big_cave? = caves[cave].big_cave?
    unvisited? = caves[cave].no_of_visits == 0
    second_visit_allowed? = cave not in ["start", "end"] and visited_no_small_cave_twice?(caves)
    big_cave? or unvisited? or second_visit_allowed?
  end

  defp visited_no_small_cave_twice?(caves) do
    Enum.all?(caves, fn {_, cave} -> cave.big_cave? or cave.no_of_visits < 2 end)
  end

  defp add_cave_visit(caves, name) do
    Map.update!(caves, name, fn c -> %{c | no_of_visits: c.no_of_visits + 1} end)
  end

  defp get_all_caves_from_connections(connections) do
    connections
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.map(&{&1, build_cave(&1, connections)})
    |> Map.new()
  end

  defp build_cave(name, connections) do
    %{
      big_cave?: Regex.match?(~r/[A-Z]+/, name),
      name: name,
      neighbors: get_neighbor_caves(name, connections),
      no_of_visits: 0
    }
  end

  defp get_neighbor_caves(name, connections) do
    connections
    |> Enum.filter(fn conn -> name in conn end)
    |> List.flatten()
    |> Enum.reject(fn n -> name == n end)
    |> Enum.uniq()
  end

  def find_octo_sync() do
    "data/2021-day11.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> line |> String.codepoints() |> Enum.map(&String.to_integer/1) end)
    |> find_sync()
  end

  defp find_sync(octopuses) do
    octopuses
    |> octopuses_to_octrix()
    |> find_sync(0)
  end

  defp find_sync(octrix, step) do
    octrix
    |> Enum.all?(fn {_, v} -> v == 0 end)
    |> Kernel.if(do: step, else: run_next_sync_step(octrix, step))
  end

  defp run_next_sync_step(octrix, step) do
    octrix
    |> calculate_new_octrix_and_flashes()
    |> elem(0)
    |> find_sync(step + 1)
  end

  def count_octopus_flashes() do
    "data/2021-day11.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> line |> String.codepoints() |> Enum.map(&String.to_integer/1) end)
    |> sim_flash_steps(100)
    |> List.flatten()
    |> length()
  end

  defp sim_flash_steps(octopuses, steps) do
    octopuses
    |> octopuses_to_octrix()
    |> print_octrix()
    |> sim_flash_step([], steps)
  end

  defp octopuses_to_octrix(octos) do
    y_max = octos |> length() |> Kernel.-(1)
    x_max = octos |> List.first() |> length() |> Kernel.-(1)
    tuples = for y <- 0..y_max, x <- 0..x_max, do: {"#{y}#{x}", get_field_value(octos, y, x)}
    Map.new(tuples)
  end

  defp sim_flash_step(octrix, flashes, steps), do: sim_flash_step({octrix, flashes}, steps)
  defp sim_flash_step({_octrix, flashes}, 0), do: flashes

  defp sim_flash_step({octrix, flashes}, steps) do
    {octrix, flashes} = octrix |> do_next_step(flashes)

    {octrix, flashes}
    |> sim_flash_step(steps - 1)
  end

  defp do_next_step(octrix, flashes) do
    {new_octrix, new_flashes} = calculate_new_octrix_and_flashes(octrix)
    {new_octrix, [new_flashes | flashes]}
  end

  defp calculate_new_octrix_and_flashes(octrix) do
    octrix
    |> Map.keys()
    |> Enum.reduce(octrix, fn k, o -> Map.update!(o, k, &(&1 + 1)) end)
    |> run_flashes()
  end

  defp print_octrix(octrix) do
    IO.puts("---")

    octrix
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.group_by(fn {<<y::binary-size(1), _::binary>>, _} -> y end)
    |> Enum.map(fn {_, v} -> Enum.map(v, fn {_, w} -> if w > 9, do: 0, else: w end) end)
    |> Enum.map(fn v -> Enum.join(v, "") end)
    |> Enum.each(&IO.puts/1)

    octrix
  end

  defp run_flashes(octrix, flash_list \\ []) do
    new_flashes =
      octrix
      |> Enum.reject(fn {coords, val} -> val < 10 or coords in flash_list end)
      |> Enum.map(fn {coords, _} -> coords end)

    case new_flashes do
      [] -> {set_flashed_to_zero(octrix, flash_list), flash_list}
      _ -> run_flashes(perform_flashes(octrix, new_flashes), flash_list ++ new_flashes)
    end
  end

  defp set_flashed_to_zero(octrix, []), do: octrix
  defp set_flashed_to_zero(octrix, [f | l]), do: set_flashed_to_zero(set_to_zero(octrix, f), l)

  defp set_to_zero(octrix, flash), do: Map.put(octrix, flash, 0)

  defp perform_flashes(octrix, []), do: octrix

  defp perform_flashes(octrix, [<<y::binary-size(1), x::binary-size(1)>> | flashes]) do
    y = String.to_integer(y)
    x = String.to_integer(x)
    keys = for yn <- (y - 1)..(y + 1), xn <- (x - 1)..(x + 1), do: "#{yn}#{xn}"
    keys = keys |> Enum.filter(fn k -> k != "#{y}#{x}" and k in Map.keys(octrix) end)

    keys
    |> Enum.reduce(octrix, fn k, o -> Map.update!(o, k, fn val -> val + 1 end) end)
    |> Map.put("#{y}#{x}", 0)
    |> perform_flashes(flashes)
  end

  def fix_incomplete_input_in_my_navigation() do
    "data/2021-day10.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> line |> String.codepoints() end)
    |> fix_incomplete_lines()
  end

  defp fix_incomplete_lines(lines) do
    lines
    |> Enum.map(&find_err_char/1)
    |> Enum.filter(&is_list/1)
    |> Enum.map(&calc_ac_score/1)
    |> Enum.sort()
    |> (&Enum.at(&1, &1 |> length() |> div(2))).()
  end

  defp calc_ac_score(chars, score \\ 0)
  defp calc_ac_score([], score), do: score
  defp calc_ac_score([c | cs], score), do: calc_ac_score(cs, score * 5 + get_ac_val(c))

  defp get_ac_val("("), do: 1
  defp get_ac_val("["), do: 2
  defp get_ac_val("{"), do: 3
  defp get_ac_val("<"), do: 4

  def uncorruptify_my_navigation() do
    "data/2021-day10.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> line |> String.codepoints() end)
    |> find_err_chars()
    |> calculate_corruption_score()
  end

  defp calculate_corruption_score([]), do: 0
  defp calculate_corruption_score([")" | cs]), do: calculate_corruption_score(cs) + 3
  defp calculate_corruption_score(["]" | cs]), do: calculate_corruption_score(cs) + 57
  defp calculate_corruption_score(["}" | cs]), do: calculate_corruption_score(cs) + 1197
  defp calculate_corruption_score([">" | cs]), do: calculate_corruption_score(cs) + 25137

  defp find_err_chars(lines) do
    lines
    |> Enum.map(&find_err_char/1)
    |> Enum.reject(&is_list/1)
  end

  @open_chars ["(", "{", "<", "["]

  defp find_err_char(chars, open_groups \\ [])
  defp find_err_char([], open_groups), do: open_groups
  defp find_err_char([c | cs], og) when c in @open_chars, do: find_err_char(cs, [c | og])
  defp find_err_char([">" | cs], ["<" | og]), do: find_err_char(cs, og)
  defp find_err_char([")" | cs], ["(" | og]), do: find_err_char(cs, og)
  defp find_err_char(["}" | cs], ["{" | og]), do: find_err_char(cs, og)
  defp find_err_char(["]" | cs], ["[" | og]), do: find_err_char(cs, og)
  defp find_err_char([corrupt_char | _], _), do: corrupt_char

  def find_basins() do
    "data/2021-day9.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> line |> String.codepoints() |> Enum.map(&String.to_integer/1) end)
    |> calculate_basins()
  end

  defp calculate_basins(heights) do
    heights
    |> find_low_points()
    |> Enum.map(&find_low_points_basin(&1, heights))
    |> Enum.map(&length/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> multiply_list()
  end

  defp multiply_list(list, value \\ 1)
  defp multiply_list([], value), do: value
  defp multiply_list([e | l], value), do: multiply_list(l, e * value)

  defp find_low_points_basin(low_point, heights) do
    low_point
    |> (fn {value, _neighbors, y, x} -> {y, x, value} end).()
    |> find_basin(heights)
    |> Enum.reject(fn {value, _y, _x} -> value == 9 end)
    |> Enum.uniq()
  end

  defp find_basin({y, x, value}, heights) do
    {y, x}
    |> find_upward_neighbors(value, heights)
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&find_basin(&1, heights))
    |> List.flatten()
    |> (&[{value, y, x} | &1]).()
  end

  defp find_upward_neighbors({y, _x}, _value, _heights) when y < 0, do: nil
  defp find_upward_neighbors({_y, x}, _value, _heights) when x < 0, do: nil
  defp find_upward_neighbors({_y, _x}, nil, _heights), do: nil
  defp find_upward_neighbors({_y, _x}, 9, _heights), do: nil

  defp find_upward_neighbors({y, x}, value, heights) do
    [{y, x - 1}, {y, x + 1}, {y - 1, x}, {y + 1, x}]
    |> Enum.map(&{&1, get_field_value(heights, &1)})
    |> Enum.reject(fn {_yx, v} -> is_nil(v) or v <= value end)
    |> Enum.map(fn {{y, x}, v} -> {y, x, v} end)
  end

  def determine_risk_level() do
    "data/2021-day9.txt"
    |> file_to_line_list()
    |> Enum.map(fn line -> line |> String.codepoints() |> Enum.map(&String.to_integer/1) end)
    |> calculate_risk_level()
  end

  defp calculate_risk_level(heights) do
    heights
    |> find_low_points()
    |> Enum.map(&elem(&1, 0))
    |> sum_low_points_up()
  end

  defp sum_low_points_up(list, sum \\ 0)
  defp sum_low_points_up([], sum), do: sum
  defp sum_low_points_up([point | points], sum), do: sum_low_points_up(points, sum + point + 1)

  defp find_low_points(heights) do
    heights
    |> get_point_with_direct_neighbor_tuples()
    |> Enum.filter(&is_low_point?/1)
  end

  defp is_low_point?({value, neighbors, _y, _x}), do: neighbors |> Enum.all?(&(&1 > value))

  defp get_point_with_direct_neighbor_tuples(heights) do
    y_max = length(heights) - 1
    x_max = length(List.first(heights)) - 1

    for y <- 0..y_max, x <- 0..x_max do
      {get_field_value(heights, y, x), get_neighbors(heights, y, x), y, x}
    end
  end

  def get_neighbors(heights, y, x) do
    [{y, x - 1}, {y, x + 1}, {y - 1, x}, {y + 1, x}]
    |> Enum.map(fn {yn, xn} -> get_field_value(heights, yn, xn) end)
    |> Enum.reject(&is_nil/1)
  end

  defp get_field_value(h, {y, x}), do: get_field_value(h, y, x)
  defp get_field_value(_h, y, _x) when y < 0, do: nil
  defp get_field_value(_h, _y, x) when x < 0, do: nil
  defp get_field_value(h, y, x), do: h |> Enum.at(y, []) |> Enum.at(x, nil)

  def decrypt_display_add_up_outputs() do
    "data/2021-day8.txt"
    |> file_to_line_list()
    |> get_inputs_and_outputs()
    |> decrypt_outputs()
    |> add_up_outputs()
  end

  defp add_up_outputs(outputs) do
    outputs
    |> Enum.map(&map_output_to_number(&1, 0))
    |> Enum.sum()
  end

  defp map_output_to_number([], counter), do: counter
  defp map_output_to_number([o | l], counter), do: map_output_to_number(l, 10 * counter + o)

  def decrypt_display_for_easy_numbers() do
    "data/2021-day8.txt"
    |> file_to_line_list()
    |> get_inputs_and_outputs()
    |> decrypt_outputs()
    |> List.flatten()
    |> Enum.filter(fn no -> no in [1, 4, 7, 8] end)
    |> length()
  end

  defp decrypt_outputs(input_output_pairs), do: Enum.map(input_output_pairs, &decrypt_output/1)

  defp decrypt_output([input, output]) do
    numbers = input |> find_numbers()
    Enum.map(output, &map_output(&1, numbers))
  end

  defp map_output(output, numbers) do
    {_, number} = Enum.find(numbers, fn {input, _} -> input == output end)
    number
  end

  defp find_numbers(input) do
    one = Enum.find(input, fn i -> length(i) == 2 end)
    two = find_two(input)
    three = find_three(input, one)
    four = Enum.find(input, fn i -> length(i) == 4 end)
    five = Enum.find(input, fn i -> length(i) == 5 and i not in [two, three] end)
    six = find_six(input, one)
    seven = Enum.find(input, fn i -> length(i) == 3 end)
    eight = Enum.find(input, fn i -> length(i) == 7 end)
    zero = find_zero(input, five)
    nine = Enum.find(input, fn i -> length(i) == 6 and i not in [zero, six] end)
    Enum.with_index([zero, one, two, three, four, five, six, seven, eight, nine])
  end

  defp find_zero(input, five) do
    input
    |> Enum.filter(fn i -> length(i) == 6 end)
    |> Enum.find(fn i -> length(i -- five) == 2 and length(five -- i) == 1 end)
  end

  defp find_two(input) do
    {right_down_symbol, 9} =
      input
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.find(fn {_k, v} -> v == 9 end)

    input |> Enum.find(fn i -> not Enum.member?(i, right_down_symbol) end)
  end

  defp find_three(input, one) do
    Enum.find(input, fn i -> length(i) == 5 and length(i -- one) == 3 end)
  end

  defp find_six(input, one) do
    input
    |> Enum.filter(fn i -> length(i) == 6 end)
    |> Enum.find(fn i -> length(i -- one) == 5 and length(one -- i) == 1 end)
  end

  defp get_inputs_and_outputs(lines), do: Enum.map(lines, &get_input_and_output/1)

  defp get_input_and_output(line) do
    line
    |> String.split("|")
    |> Enum.map(&sanitize_crypted_numbers/1)
  end

  defp sanitize_crypted_numbers(numbers) do
    numbers
    |> String.split(" ")
    |> Enum.reject(fn str -> str == "" end)
    |> Enum.map(fn str -> str |> String.codepoints() |> Enum.sort() end)
  end

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
