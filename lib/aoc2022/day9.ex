defmodule Aoc2022.Day9 do
  @examples [
    {:first_task, "data/2022-day9-test.txt", :noop},
    {:first_task, "data/2022-day9.txt", :noop},
    {:second_task, "data/2022-day9-test.txt", :noop},
    {:second_task, "data/2022-day9.txt", :noop}
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
