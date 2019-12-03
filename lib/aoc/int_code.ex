defmodule AOC.IntCode do

  def calculate_int_code() do
    get_int_code()
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2) 
    |> run_int_code()
  end

  def find_input_pair_for(target) do
    start_code = get_int_code()
    for noun <- 0..99, verb <- 0..99 do
      result =
        start_code
        |> List.replace_at(1, noun)
        |> List.replace_at(2, verb)
        |> run_int_code()
        |> Enum.at(0)
      if result == target do
        IO.puts("A valid response would be #{100 * noun + verb}!")
      end
    end
  end

  def get_int_code() do
    File.read!("data/day2.txt")
    |> String.trim
    |> String.split(",")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(&String.to_integer/1)
  end

  def run_int_code(list) do
    list |> run_op_at(0)
  end

  def run_op_at(list, op_pos) do
    operator = Enum.at(list, op_pos)
    case operator do
      1 -> do_op(list, op_pos, &Kernel.+/2)
      2 -> do_op(list, op_pos, &Kernel.*/2)
      99 -> list
      _ -> raise "unknown code"
    end
  end

  def do_op(list, op_pos, func) do
    op_left = Enum.at(list, Enum.at(list, op_pos + 1))
    op_right = Enum.at(list, Enum.at(list, op_pos + 2))
    result_pos = Enum.at(list, op_pos + 3)
    result = func.(op_left, op_right)
    run_op_at(List.replace_at(list, result_pos, result), op_pos + 4)
  end
end
