defmodule AOC.Expenses do

  def get_two_right_expenses() do
    "data/2020-day1.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(&String.to_integer/1)
    |> find_pair(2020)
  end

  
  def get_three_right_expenses() do
    "data/2020-day1.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(&String.to_integer/1)
    |> find_triple(2020)
  end

  defp find_triple([], _), do: 0
  defp find_triple([val1 | rest], sum) do
    target = sum - val1
    case find_pair(rest, target) do
      0 -> find_triple(rest, sum)
      res -> val1 * res 
    end
  end

  defp find_pair([], _), do: 0
  defp find_pair([val1 | rest], sum) do
    target = sum - val1
    
    case Enum.find(rest, &(&1 == target)) do
      nil -> find_pair(rest, sum)
      val2 -> val1 * val2
    end
  end

end
