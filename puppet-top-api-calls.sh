#!/usr/bin/env bash

# Original vesion by https://github.com/sharpie

# TODO: check for number of fields in access log when using -b
# Figure out how to graph with -b
# Plot counts

cleanup() {
  for f in "${tmp_files[@]}"; do
    rm -- "$f"
  done
}
trap cleanup EXIT

[[ $@ =~ --help ]] && {
  cat <<EOF
usage: top-api-calls.sh [-b] [-g] [-c] <access_files>
  -b uses the JRuby borrow time instead of overall duration
  -g plots the average durations in gnuplot
     -c can be used in combination with -g to plot counts
EOF
exit
}

mlr_tmp="$(mktemp)"
tmp_files+=("$mlr_tmp")

while getopts ":bgc" opt; do
  case "$opt" in
    b)
      borrow=true
      ;;
    g)
      type gnuplot &>/dev/null || {
        echo "gnuplot not found"
        exit 1
      }
      graph=true
      ;;
    c)
      count=true
    esac
  done

shift $((OPTIND-1))

if [[ $graph && $borrow ]]; then
  printf "%s\n" "Graphing output of borrow times currently not supported" >&2
  unset graph
fi

for file in "$@"; do
  printf 'Processing: %s\n' "$file" >&2

  case "${file##*.}" in
    gz)
      read_cmd=(gunzip -c)
      ;;
    *)
      read_cmd=(cat)
      ;;
  esac

  case "${file##*/}" in
    puppetserver-access*)
      if [[ $borrow ]]; then duration_field=0; else duration_field=2; fi

      "${read_cmd[@]}" "$file" \
        | gawk -v n="$duration_field" \
          'BEGIN { print "date,path,duration" }
               {
                 match($7, /(\/[^\/?]+){3}/, path)
                 print $4 $5 "," path[0] "," $(NF-n);
               }' \
        | mlr --icsv --opprint \
            put '$date = strptime_local($date, "[%d/%b/%Y:%H:%M:%S%z]");
                 $date = strftime_local(roundm($date, 1800), "%Y-%m-%dT%H:%M:%S");' \
            then stats1 -f duration -g date,path -a count,p50,p99 \
            then top -f duration_count -g date -n 10 -a >>"$mlr_tmp"
        ;;
    # The entries in PDB logs that we are about are either /nodes or /cmd
    # For /cmd we can parse out the command from /command= and add it to the path
    puppetdb-access*)
      if [[ $borrow ]]; then printf "%s\n" "WARN: PDB does not use JRuby.  Disabling borrow option"; fi

      "${read_cmd[@]}" "$file" \
        | gawk -v n="$duration_field" \
          'BEGIN { print "date,path,duration" }
               {
                 match($7, /(\/[^\/?]+){3,4}/, path)
                 n = split(path[0], s, "/")
                 if (path[0] ~ "/nodes") {
                   print $4 $5 "," path[0] "," $(NF-1);
                 }
                 else if (path[0] ~ "/cmd") {
                   match($7, /command=[a-z_]*/, cmd)
                   split(cmd[0], s, "=")
                   print $4 $5 "," path[0] "/" s[2] "," $(NF-1);
                 }
               }' \
        | mlr --icsv --opprint \
            put '$date = strptime_local($date, "[%d/%b/%Y:%H:%M:%S%z]");
                 $date = strftime_local(roundm($date, 1800), "%Y-%m-%dT%H:%M:%S");' \
            then stats1 -f duration -g date,path -a count,p50,p99 \
            then top -f duration_count -g date -n 10 -a >>"$mlr_tmp"
        ;;
      *)
        printf "%s\n" "WARN: $file not supported" >&2
  esac

done

[[ $graph ]] || {
  cat "$mlr_tmp"
  exit
}

plot_tmp="$(mktemp)"
tmp_files+=("$plot_tmp")

# TODO: remember how tf this works
if [[ $count ]]; then mlr_field=3; else mlr_field=4; fi
sed '/^date/d' "$mlr_tmp" | sort -k2,2 \
  | gawk -v n="$mlr_field" 'NR == 1 { printf "\"%s\"\n", $2 } NR >1 && prev != $2 { print ""; print ""; printf "\"%s\"\n", $2} { print $1 " " $n }  { prev = $2 }' >"$plot_tmp"

gnuplot <<EOF
set timefmt '%Y-%m-%dT%H:%M-%S'
set format x "%d-%b\n%H:%M"
set xdata time
plot for [i=0:*] '$plot_tmp' index i using 1:2 with lines title columnheader(1)
pause mouse close
EOF
