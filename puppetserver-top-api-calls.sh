#!/usr/bin/env bash

# Original vesion by https://github.com/sharpie

# TODO: check for number of fields in access log when using -b
# Figure out how to graph with -b

cleanup() {
  for f in "${tmp_files[@]}"; do
    rm -- "$f"
  done
}
trap cleanup EXIT

[[ $@ =~ --help ]] && {
  cat <<EOF
usage: top-api-calls.sh [-b] [-g] <access_files>
  -b uses the JRuby borrow time instead of overall duration
  -g plots the output in gnuplot
EOF
}

mlr_tmp="$(mktemp)"
tmp_files+=("$mlr_tmp")

duration_field=2
while getopts ":bg" opt; do
  case "$opt" in
    b)
      duration_field=0
      ;;
    g)
      type gnuplot &>/dev/null || {
        echo "gnuplot not found"
        exit 1
      }
      graph=true
    esac
  done

shift $((OPTIND-1))
if [[ $graph ]] && (( duration_field == 0 )); then
  printf "%s\n" "Graphing output of borrow times currently not supported" >&2
  unset graph
fi

for file in "$@"; do
  printf 'Processing: %s\n' "$file" >&2

  case "${file##*/}" in
    *.gz)
      read_cmd=(gunzip -c)
      ;;
    *)
      read_cmd=(cat)
      ;;
  esac

  "${read_cmd[@]}" "$file" \
    | gawk -vn="$duration_field" 'BEGIN { print "date,path,duration" }
           {
             match($7, /(\/[^\/?]+){3}/, path)
             print $4 $5 "," path[0] "," $(NF-n);
           }' \
    | mlr --icsv --opprint \
        put '$date = strptime_local($date, "[%d/%b/%Y:%H:%M:%S%z]");
             $date = strftime_local(roundm($date, 1800), "%Y-%m-%dT%H:%M:%S");' \
        then stats1 -f duration -g date,path -a count,p50,p99 \
        then top -f duration_count -g date -n 10 -a >>"$mlr_tmp"
done

[[ $graph ]] || {
  cat "$mlr_tmp"
  exit
}

plot_tmp="$(mktemp)"
tmp_files+=("$plot_tmp")

# TODO: remember how tf this works
sed '/^date/d' "$mlr_tmp" | sort -k2,2 \
  | awk 'NR == 1 { printf "\"%s\"\n", $2 } NR >1 && prev != $2 { print ""; print ""; printf "\"%s\"\n", $2} { print $1 " " $4 }  { prev = $2 }' >"$plot_tmp"

gnuplot <<EOF
set timefmt '%Y-%m-%dT%H:%M-%S'
set format x "%d-%b\n%H:%M"
set xdata time
plot for [i=0:*] '$plot_tmp' index i using 1:2 with lines title columnheader(1)
pause mouse close
EOF
