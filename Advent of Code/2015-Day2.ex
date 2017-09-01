# Day2 - Elixir
# Xophidia


defmodule Day1_2015 do
  def calcul(dimension) do
    [l,w,h] = dimension
    one = [l,w] |> Enum.reduce(fn(x, acc) -> x * acc * 2 end)
    two = [w,h] |> Enum.reduce(fn(x, acc) -> x * acc * 2 end)
    three = [l,h] |> Enum.reduce(fn(x, acc) -> x * acc * 2 end)
    slack = dimension |> Enum.sort |> Enum.take(2) |> Enum.reduce(fn(x, acc) -> x * acc end)
    one + two + three + slack
  end
end

file = File.read!("day2.txt") |> String.strip |> String.split("\n")
tuple = for line <- file, do: Enum.map(String.split(line, "x"), &String.to_integer/1)
IO.inspect Enum.map(tuple, &Day1_2015.calcul/1) |> Enum.sum

IO.inspect Day1_2015.calcul([1,2,3]) == 24
