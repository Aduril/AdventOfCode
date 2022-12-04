defmodule Aoc2022.Day13 do
  @examples [
    {:first_task, "data/2022-day13-test.txt", :noop},
    {:first_task, "data/2022-day13.txt", :noop},
    {:second_task, "data/2022-day13-test.txt", :noop},
    {:second_task, "data/2022-day13.txt", :noop}
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
