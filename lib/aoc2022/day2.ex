defmodule Aoc2022.Day2 do
  @examples [
    {:first_task, "data/2022-day2-test.txt", 15},
    {:first_task, "data/2022-day2.txt", 9241},
    {:second_task, "data/2022-day2-test.txt", 12},
    {:second_task, "data/2022-day2.txt", 14610}
  ]

  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&calculate_game_result/1)
    |> Enum.sum()
  end

  def second_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&calculate_my_value/1)
    |> Enum.map(&calculate_game_result/1)
    |> Enum.sum()
  end

  defp calculate_game_result([opponent, myself]) do
    myself
    |> calculate_picked_value()
    |> Kernel.+(calculate_game_value(opponent, myself))
  end

  defp calculate_picked_value("X"), do: 1
  defp calculate_picked_value("Y"), do: 2
  defp calculate_picked_value("Z"), do: 3

  defp calculate_game_value("A", "X"), do: 3
  defp calculate_game_value("A", "Y"), do: 6
  defp calculate_game_value("A", "Z"), do: 0
  defp calculate_game_value("B", "X"), do: 0
  defp calculate_game_value("B", "Y"), do: 3
  defp calculate_game_value("B", "Z"), do: 6
  defp calculate_game_value("C", "X"), do: 6
  defp calculate_game_value("C", "Y"), do: 0
  defp calculate_game_value("C", "Z"), do: 3

  defp calculate_my_value(["A", "X"]), do: ["A", "Z"]
  defp calculate_my_value(["A", "Y"]), do: ["A", "X"]
  defp calculate_my_value(["A", "Z"]), do: ["A", "Y"]
  defp calculate_my_value(["B", "X"]), do: ["B", "X"]
  defp calculate_my_value(["B", "Y"]), do: ["B", "Y"]
  defp calculate_my_value(["B", "Z"]), do: ["B", "Z"]
  defp calculate_my_value(["C", "X"]), do: ["C", "Y"]
  defp calculate_my_value(["C", "Y"]), do: ["C", "Z"]
  defp calculate_my_value(["C", "Z"]), do: ["C", "X"]
end
