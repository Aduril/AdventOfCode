defmodule Aoc2022.Day8 do
  @examples [
    {:first_task, "data/2022-day8-test.txt", 21},
    {:first_task, "data/2022-day8.txt", 1796},
    {:second_task, "data/2022-day8-test.txt", 8},
    {:second_task, "data/2022-day8.txt", 288_120}
  ]
  use Extensions

  def first_task(input) do
    input
    |> file_to_line_list()
    |> get_tree_list()
    |> find_visible_trees()
    |> Enum.count()
  end

  def second_task(input) do
    input
    |> file_to_line_list()
    |> get_tree_list()
    |> get_scenic_score_per_tree()
    |> Enum.max()
  end

  defp get_tree_list(lines) do
    lines
    |> Enum.map(&index_horizontal/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {l, vi} -> Enum.map(l, fn {v, hi} -> {vi, hi, v} end) end)
  end

  defp find_visible_trees(trees) do
    trees
    |> Enum.filter(&visible?(&1, trees))
  end

  defp visible?(t, ts) do
    visible_right?(t, ts) || visible_left?(t, ts) || visible_top?(t, ts) || visible_down?(t, ts)
  end

  defp visible_right?({vi, hi, height}, trees) do
    trees
    |> Enum.any?(fn {tvi, thi, theight} -> tvi > vi && thi == hi && theight >= height end)
    |> Kernel.not()
  end

  defp visible_left?({vi, hi, height}, trees) do
    trees
    |> Enum.any?(fn {tvi, thi, theight} -> tvi < vi && thi == hi && theight >= height end)
    |> Kernel.not()
  end

  defp visible_top?({vi, hi, height}, trees) do
    trees
    |> Enum.any?(fn {tvi, thi, theight} -> tvi == vi && thi < hi && theight >= height end)
    |> Kernel.not()
  end

  defp visible_down?({vi, hi, height}, trees) do
    trees
    |> Enum.any?(fn {tvi, thi, theight} -> tvi == vi && thi > hi && theight >= height end)
    |> Kernel.not()
  end

  defp index_horizontal(line) do
    line
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
  end

  defp get_scenic_score_per_tree(trees) do
    trees
    |> Enum.map(&get_scenic_score(&1, trees))
  end

  defp get_scenic_score(tree, trees) do
    right_score = tree |> get_right_trees(trees) |> calc_score(tree)
    left_score = tree |> get_left_trees(trees) |> calc_score(tree)
    top_score = tree |> get_top_trees(trees) |> calc_score(tree)
    down_score = tree |> get_down_trees(trees) |> calc_score(tree)
    right_score * left_score * top_score * down_score
  end

  defp get_right_trees({vi, hi, _}, trees) do
    trees
    |> Enum.filter(fn {tvi, thi, _} -> tvi > vi && thi == hi end)
    |> Enum.sort_by(fn {tvi, _, _} -> tvi end, :asc)
    |> Enum.map(fn {_, _, theight} -> theight end)
  end

  defp get_left_trees({vi, hi, _}, trees) do
    trees
    |> Enum.filter(fn {tvi, thi, _} -> tvi < vi && thi == hi end)
    |> Enum.sort_by(fn {tvi, _, _} -> tvi end, :desc)
    |> Enum.map(fn {_, _, theight} -> theight end)
  end

  defp get_top_trees({vi, hi, _}, trees) do
    trees
    |> Enum.filter(fn {tvi, thi, _} -> tvi == vi && thi < hi end)
    |> Enum.sort_by(fn {_, thi, _} -> thi end, :desc)
    |> Enum.map(fn {_, _, theight} -> theight end)
  end

  defp get_down_trees({vi, hi, _}, trees) do
    trees
    |> Enum.filter(fn {tvi, thi, _} -> tvi == vi && thi > hi end)
    |> Enum.sort_by(fn {_, thi, _} -> thi end, :asc)
    |> Enum.map(fn {_, _, theight} -> theight end)
  end

  defp calc_score([], _tree), do: 0
  defp calc_score([th | r], {_, _, h} = t), do: if(th >= h, do: 1, else: 1 + calc_score(r, t))
end
