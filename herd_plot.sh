#!/usr/bin/env bash

cleanup() {
  for f in "${tmp_files[@]}"; do
    rm -- "$f"
  done
}

trap cleanup EXIT

type gnuplot &>/dev/null || {
  echo "gnuplot not found"
  exit 1
}

(( ${#@} == 1 )) || {
  cat <<EOF
This script takes a single argument: the path to the thundering herd query file
EOF
  exit 1
}

awk_tmp="$(mktemp)"
tmp_files+=("$awk_tmp")
plot_tmp="$(mktemp)"
tmp_files+=("$plot_tmp")

script_dir="${BASH_SOURCE[0]%/*}"
awk -F '|' -f "${script_dir}/herd_plot.awk" <"$1" | tac >"$awk_tmp"

cat >"$plot_tmp" <<EOF
set xdata time
set timefmt '%m/%d/%H:%M'
set format x "%m/%d\n%H:%M"
plot '$awk_tmp' using 1:2 title "Agents" pt 7 ps 3
pause -1
EOF

gnuplot "$plot_tmp"

