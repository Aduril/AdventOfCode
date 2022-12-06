defmodule Aoc2022.Day5 do
  @examples [
    {:first_task, "data/2022-day5-test.txt", "CMZ"},
    {:first_task, "data/2022-day5.txt", "FWSHSPJWM"},
    {:second_task, "data/2022-day5-test.txt", "MCD"},
    {:second_task, "data/2022-day5.txt", "PWPWHGFZS"}
  ]
  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list(false)
    |> split_input()
    |> prepare_stacks()
    |> prepare_instructions()
    |> insert_crates()
    |> follow_instructions_one_crate_at_a_time()
    |> get_top_crates()
  end

  def second_task(input) do
    input
    |> file_to_line_list(false)
    |> split_input()
    |> prepare_stacks()
    |> prepare_instructions()
    |> insert_crates()
    |> follow_instructions_multiple_crates_at_a_time()
    |> get_top_crates()
  end

  defp split_input(board \\ [], input)
  defp split_input(board, ["" | instructions]), do: {board, instructions}
  defp split_input(board, [line | lines]), do: split_input([line | board], lines)

  defp prepare_stacks({[stack_names | crates], instructions}) do
    stack_names
    |> String.codepoints()
    |> Enum.chunk_every(4)
    |> Enum.map(&List.to_string/1)
    |> Enum.map(&String.trim/1)
    |> prepare_map()
    |> (&{&1, crates, instructions}).()
  end

  defp prepare_map(keys, map \\ %{})
  defp prepare_map([], map), do: map
  defp prepare_map([key | keys], map), do: prepare_map(keys, Map.put(map, key, []))

  defp prepare_instructions({stack, crates, instructions}) do
    instructions
    |> Enum.reject(fn line -> line == "" end)
    |> Enum.map(&prepare_instruction/1)
    |> (&{stack, crates, &1}).()
  end

  defp prepare_instruction(instruction) do
    instruction
    |> String.split(~r{(move | from | to )}, trim: true)
    |> make_instruction_tuple()
  end

  defp make_instruction_tuple([no, source, target]), do: {String.to_integer(no), source, target}

  defp insert_crates({stacks, crates, instructions}) do
    crates
    |> Enum.map(&prepare_crate_line/1)
    |> List.flatten()
    |> Enum.reduce(stacks, &insert_into_stacks(&1, &2))
    |> (&{&1, instructions}).()
  end

  defp prepare_crate_line(line) do
    line
    |> String.codepoints()
    |> Enum.chunk_every(4)
    |> Enum.map(&List.to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&(&1 |> String.replace("[", "") |> String.replace("]", "")))
    |> Enum.with_index(1)
  end

  defp insert_into_stacks({"", _}, stacks), do: stacks
  defp insert_into_stacks({c, i}, stacks), do: Map.update(stacks, "#{i}", [], fn s -> [c | s] end)

  defp follow_instructions_one_crate_at_a_time({board, instructions}) do
    Enum.reduce(instructions, board, &move_crates/2)
  end

  defp move_crates({0, _source, _target}, board), do: board
  defp move_crates({no, s, t}, board), do: move_crates({no - 1, s, t}, move_crate(board, s, t))

  defp move_crate(board, s, t), do: board |> Map.get(s) |> List.first() |> move_crate(board, s, t)

  defp move_crate(nil, board, _, _), do: board
  defp move_crate(c, board, source, target), do: move_existing_crate(c, board, source, target)

  defp move_existing_crate(crate, board, source, target) do
    board
    |> Map.update(source, [], fn [_ | rest] -> rest end)
    |> Map.update(target, [], fn list -> [crate | list] end)
  end

  defp get_top_crates(board) do
    board
    |> Map.keys()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort(:asc)
    |> Enum.map(&(board |> Map.get("#{&1}", []) |> List.first("")))
    |> Enum.join("")
  end

  defp follow_instructions_multiple_crates_at_a_time({board, instructions}) do
    Enum.reduce(instructions, board, &move_multiple_crates/2)
  end

  defp move_multiple_crates({no, s, t}, board) do
    {crates, source_stack} = board |> Map.get(s, []) |> Enum.split(no)

    board
    |> Map.put(s, source_stack)
    |> Map.update(t, [], fn target -> crates ++ target end)
  end
end
