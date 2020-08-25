#!/bin/bash

while getopts ":t:f:" opt; do
  case "$opt" in
    t)
      table="$OPTARG"
      ;;
    :)
      echo "Option -$OPTARG requires a table as an argument." >&2
      exit 1
      ;;

    esac
  done

shift $((OPTIND-1))

(( ${#@} == 1 )) || {
  cat <<EOF
This script takes a single argument: the path to db_relation_sizes_by_table.txt
-t <table> may be used to calculate usage for a table other than resource_events
   specify the full string to match against, e.g. pe-puppetdb.reports
EOF
  exit 1
}

type numfmt &>/dev/null || {
  echo "numfmt utility required.  Please install GNU coreutils"
  exit 1
}

script_dir="${BASH_SOURCE[0]%/*}"

awk -F '|' -v table="${table:-pe-puppetdb.resource_events}" -f "${script_dir}/partition_sum.awk" <"$1"
