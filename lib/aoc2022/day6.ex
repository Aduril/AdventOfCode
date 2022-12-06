defmodule Aoc2022.Day6 do
  @examples [
    {:first_task, "data/2022-day6-test.txt", [7, 5, 6, 10, 11]},
    {:first_task, "data/2022-day6.txt", [1542]},
    {:second_task, "data/2022-day6-test.txt", [19, 23, 23, 29, 26]},
    {:second_task, "data/2022-day6.txt", [3153]}
  ]
  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&find_first_uniq_string(&1, 4))
  end

  def second_task(input) do
    input
    |> file_to_line_list()
    |> Enum.map(&find_first_uniq_string(&1, 14))
  end

  defp find_first_uniq_string(<<_::binary-size(1), rest::binary>> = string, length, counter \\ 0) do
    if uniq_string?(string, length) do
      counter + length
    else
      find_first_uniq_string(rest, length, counter + 1)
    end
  end

  defp uniq_string?(string, length) do
    string
    |> String.slice(0, length)
    |> String.codepoints()
    |> has_duplicates?()
    |> Kernel.!()
  end

  defp has_duplicates?([]), do: false
  defp has_duplicates?([a | rest]), do: Enum.member?(rest, a) or has_duplicates?(rest)
end
