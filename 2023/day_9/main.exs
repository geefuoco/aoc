defmodule Main do

  def read_input(filepath) do
    {success, input} = File.read(filepath)
    if success != :ok do
      IO.puts("Could not read file: #{filepath}")
      System.halt(1)
    end
    input
  end

  def find_prev_number(numbers) do
    diffs = Enum.zip(numbers, tl(numbers))
      |> Enum.reduce([], fn {current, next}, acc -> [current - next| acc] end)
      |> Enum.reverse()

    result = Enum.filter(diffs, fn x -> x != 0 end)
    if length(result) != 0 do
      find_prev_number(diffs) + List.first(numbers)
    else
      List.first(numbers)
    end
  end

  def find_next_number(numbers) do
    diffs = Enum.zip(numbers, tl(numbers))
      |> Enum.reduce([], fn {current, next}, acc -> [next - current | acc] end)
      |> Enum.reverse()

    result = Enum.filter(diffs, fn x -> x != 0 end)
    if length(result) != 0 do
      find_next_number(diffs) + List.last(numbers)
    else
      List.last(numbers)
    end
  end

  def main() do
    args = System.argv()
    if length(args) < 1 do
      IO.puts("Usage\telixir main.exs <filepath>")
      System.halt(1)
    end

    [filepath | _rest] = args
    input = read_input(filepath)
    lines = Enum.filter(String.split(input, "\n"), fn x -> x != "" end)
    final_result = Enum.reduce(lines, 0, fn x, acc -> 
      nums = Enum.map(String.split(x), fn y -> String.to_integer(y) end)
      acc + find_prev_number(nums)
    end)

    IO.puts(final_result)
  end

end

Main.main()
