defmodule Aoc2022.Day3 do
  @examples [
    {:first_task, "data/2022-day3-test.txt", 157},
    {:first_task, "data/2022-day3.txt", 7793},
    {:second_task, "data/2022-day3-test.txt", 70},
    {:second_task, "data/2022-day3.txt", 2499}
  ]

  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&split_in_two/1)
    |> Enum.map(&find_shared_symbol/1)
    |> Enum.map(&assign_values/1)
    |> Enum.sum()
  end

  def second_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&find_shared_symbol/1)
    |> Enum.map(&assign_values/1)
    |> Enum.sum()
  end

  defp split_in_two(str) do
    str
    |> String.to_charlist()
    |> Enum.chunk_every(find_split_point(str, 2))
  end

  defp find_split_point(str, no_of_chunks) do
    str
    |> String.length()
    |> div(no_of_chunks)
  end

  defp find_shared_symbol([first | rest]) do
    Enum.find(first, fn symbol -> Enum.reduce(rest, true, &(&2 and Enum.member?(&1, symbol))) end)
  end

  defp assign_values(char) when char < 97, do: char - 38
  defp assign_values(char), do: char - 96
end
