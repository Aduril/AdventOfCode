defmodule Aoc2022.Day7 do
  @examples [
    {:first_task, "data/2022-day7-test.txt", 95437},
    {:first_task, "data/2022-day7.txt", 1_348_005},
    {:second_task, "data/2022-day7-test.txt", 24_933_642},
    {:second_task, "data/2022-day7.txt", 12_785_886}
  ]
  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list()
    |> build_tree()
    |> Map.get("/")
    |> find_dir_sizes()
    |> Enum.filter(fn x -> x <= 100_000 end)
    |> Enum.sum()
  end

  def second_task(input) do
    input
    |> file_to_line_list()
    |> build_tree()
    |> Map.get("/")
    |> find_dir_sizes()
    |> Enum.sort(:desc)
    |> (&find_dir_to_delete(&1, List.first(&1))).()
  end

  defp build_tree(lines, tree \\ %{})
  defp build_tree([], tree), do: tree |> Map.delete(:wd)
  defp build_tree([line | lines], tree), do: build_tree(lines, add_to_tree(tree, line))

  defp add_to_tree(tree, <<"$ cd ", path::binary>>), do: cd(tree, path)
  defp add_to_tree(tree, "$ ls"), do: tree
  defp add_to_tree(tree, content), do: add_content_to_dir(tree, content)

  defp cd(tree, ".."), do: Map.update(tree, :wd, [], &remove_from_tail/1)
  defp cd(tree, wd), do: tree |> Map.update(:wd, [wd], &append_to_tail(&1, wd)) |> add_path(wd)

  defp remove_from_tail([]), do: []
  defp remove_from_tail([_ | []]), do: []
  defp remove_from_tail([v | list]), do: [v | remove_from_tail(list)]

  defp append_to_tail([], path), do: [path]
  defp append_to_tail([v | list], path), do: [v | append_to_tail(list, path)]

  defp add_path(tree, dir), do: Map.put_new(tree, dir, %{})

  defp add_content_to_dir(%{wd: wd} = tree, content) do
    content
    |> parse_content()
    |> (&(tree |> put_into_wd(wd, &1) |> update_sizes(wd, &1))).()
  end

  defp put_into_wd(tree, [], {key, value, _type}), do: Map.put_new(tree, key, value)

  defp put_into_wd(t, [d | l], c) do
    Map.update!(t, d, &put_into_wd(&1, l, c))
  end

  defp parse_content(["dir", dir_name]), do: {dir_name, %{}, :dir}
  defp parse_content([size, file_name]), do: {file_name, String.to_integer(size), :file}
  defp parse_content(str), do: str |> String.split(" ") |> parse_content()

  defp update_sizes(tree, _, {_, _, :dir}), do: tree
  defp update_sizes(tree, wd, {_, size, :file}), do: update_dir_sizes(tree, wd, size)

  defp update_dir_sizes(tree, [], _size), do: tree
  defp update_dir_sizes(tree, [dir | l], size), do: Map.update!(tree, dir, &add_size(&1, l, size))

  defp add_size(dir, list, size) do
    dir
    |> Map.update(:size, size, fn s -> s + size end)
    |> update_dir_sizes(list, size)
  end

  defp find_dir_sizes(%{} = tree), do: find_dir_size(tree)
  defp find_dir_sizes(_tree), do: 0

  defp find_dir_size(%{size: size} = dir) do
    dir
    |> Map.keys()
    |> Enum.reject(fn k -> k == :size end)
    |> Enum.map(&find_dir_sizes(Map.get(dir, &1)))
    |> (&[size | &1]).()
    |> List.flatten()
  end

  defp find_dir_to_delete(sizes, used_spc, total_spc \\ 70_000_000, required_spc \\ 30_000_000) do
    sizes
    |> Enum.reject(fn size -> used_spc + required_spc - total_spc > size end)
    |> List.last()
  end
end
