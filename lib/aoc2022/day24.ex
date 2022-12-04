defmodule Aoc2022.Day24 do
  @examples [
    {:first_task, "data/2022-day24-test.txt", :noop},
    {:first_task, "data/2022-day24.txt", :noop},
    {:second_task, "data/2022-day24-test.txt", :noop},
    {:second_task, "data/2022-day24.txt", :noop}
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
