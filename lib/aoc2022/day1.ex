defmodule Aoc2022.Day1 do
  @examples [
    {:first_task, "data/2022-day1-test.txt", 24000},
    {:first_task, "data/2022-day1.txt", 70698},
    {:second_task, "data/2022-day1-test.txt", 45000},
    {:second_task, "data/2022-day1.txt", 206_643}
  ]

  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list(false)
    |> divide_elves()
    |> Enum.map(&sum_up_calories/1)
    |> Enum.sort(:desc)
    |> List.first()
  end

  defp divide_elves(calorie_list) do
    calorie_list
    |> Enum.reduce([], &add_calorie_value(&1, &2))
    |> Enum.reject(&(&1 == []))
  end

  defp sum_up_calories(list) do
    list
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp add_calorie_value("", list), do: [[] | list]
  defp add_calorie_value(value, []), do: [[value]]
  defp add_calorie_value(value, [elv_cal_list | list]), do: [[value | elv_cal_list] | list]

  def second_task(input) do
    input
    |> file_to_line_list(false)
    |> divide_elves()
    |> Enum.map(&sum_up_calories/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end
