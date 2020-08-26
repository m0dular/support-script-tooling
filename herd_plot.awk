#!/usr/bin/awk -f

# Run via herd_plot.sh

{ gsub(" ", "", $0) }

$1 ~ "^[0-9]" {
  print $1 "/" $2 "/" $3 ":" $4 " " $5
}
