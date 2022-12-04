defmodule Aoc2022.Day10 do
  @examples [
    {:first_task, "data/2022-day10-test.txt", :noop},
    {:first_task, "data/2022-day10.txt", :noop},
    {:second_task, "data/2022-day10-test.txt", :noop},
    {:second_task, "data/2022-day10.txt", :noop}
  ]
  use Extensions
  def first_task(input) do
    input
    |> file_to_line_list()
  end
  def second_task(input) do
    input
    |> file_to_line_list()
  end
end
