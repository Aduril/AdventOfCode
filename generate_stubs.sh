#!/bin/zsh

year=$1
basedir=$(dirname $0)
datadir="$basedir/data"
libdir="$basedir/lib"
yeardir="$basedir/lib/aoc${year}"

if [ -z "$year" ]; then echo "please enter a year"; exit 1; fi
mkdir -p "$yeardir"
for i in $(seq 1 24); do
  dayfile="${yeardir}/day${i}.ex"
  if [ -e "$dayfile" ]; then
    echo "File $dayfile already exists! Therefore, I will skip it!";
    continue;
  fi
  touch "$dayfile"
  echo "defmodule Aoc${year}.Day${i} do"                               >> "$dayfile"
  echo "  @examples ["                                            >> "$dayfile"
  echo "    {:first_task, \"data/${year}-day${i}-test.txt\", :noop},"  >> "$dayfile"
  echo "    {:first_task, \"data/${year}-day${i}.txt\", :noop},"       >> "$dayfile"
  echo "    {:second_task, \"data/${year}-day${i}-test.txt\", :noop}," >> "$dayfile"
  echo "    {:second_task, \"data/${year}-day${i}.txt\", :noop}"       >> "$dayfile"
  echo "  ]"                                                     >> "$dayfile"
  echo "  use Extensions"                                        >> "$dayfile"
  echo "  def first_task(input) do"                              >> "$dayfile"
  echo "    input"                                               >> "$dayfile"
  echo "    |> file_to_line_list()"                              >> "$dayfile"
  echo "  end"                                                   >> "$dayfile"
  echo "  def second_task(input) do"                             >> "$dayfile"
  echo "    input"                                               >> "$dayfile"
  echo "    |> file_to_line_list()"                              >> "$dayfile"
  echo "  end"                                                   >> "$dayfile"
  echo "end"                                                     >> "$dayfile"
  touch "$datadir/${year}-day${i}-test.txt"
  touch "$datadir/${year}-day${i}.txt"
done

