defmodule AOC.FuelCalculator do

  def calculate_fuel_requirements() do
    get_module_masses()
    |> Enum.reduce(0, &add_fuel_requirement/2)
  end

  def get_module_masses() do
    File.read!("data/day1.txt")
    |> String.split("\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(&String.to_integer/1)
  end

  def add_fuel_requirement(mass, fuel_sum) do
    calculate_fuel_requirements_for_mass(mass) + fuel_sum
  end

  def calculate_fuel_requirements_for_mass(mass) when mass < 9, do: 0
  def calculate_fuel_requirements_for_mass(mass) do
    req_fuel = Float.floor(mass/3) - 2
    req_fuel + calculate_fuel_requirements_for_mass(req_fuel)
  end
end
