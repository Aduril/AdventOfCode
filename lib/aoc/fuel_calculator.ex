defmodule AOC.FuelCalculator do

  def calculate_fuel_requirements() do
    get_module_masses()
    |> Enum.reduce(0, &add_fuel_requirement/2)
  end

  def get_module_masses() do
    HTTPoison.get!("https://adventofcode.com/2019/day/1/input", [Cookie: "session=53616c7465645f5f7af2f187bd151887a037eeed580c0de7453a7da71ea093b02ede43270781d26d653d007e90da85fa"])
    |> Map.get(:body)
    |> String.split("\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(&String.to_integer/1)
  end

  def add_fuel_requirement(mass, fuel_sum) do
    calculate_fuel_requirements_for_mass(mass) + fuel_sum
  end

  def calculate_fuel_requirements_for_mass(mass) do
    Float.floor(mass/3) - 2
  end
end
