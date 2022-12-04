defmodule Aoc2022.Day4 do
  @examples [
    {:first_task, "data/2022-day4-test.txt", 2},
    {:first_task, "data/2022-day4.txt", 490},
    {:second_task, "data/2022-day4-test.txt", 4},
    {:second_task, "data/2022-day4.txt", :research}
  ]

  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&make_range_tuples/1)
    |> Enum.filter(&has_subset?/1)
    |> length()
  end

  def second_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&make_range_tuples/1)
    |> Enum.filter(&has_overlap?/1)
    |> length()
  end

  defp make_range_tuples(line) do
    line
    |> String.split(",")
    |> Enum.map(&make_range_tuple/1)
  end

  defp make_range_tuple(str) do
    str
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp has_subset?([{fb, fl}, {sb, sl}]), do: (fb <= sb and fl >= sl) or (sb <= fb and sl >= fl)

  defp has_overlap?([{fb, fl}, {sb, sl}]), do: (sb >= fb and sb <= fl) or (fb >= sb and fb <= sl)
end
