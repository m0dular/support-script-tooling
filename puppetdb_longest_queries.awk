#!/usr/bin/env -S gawk -f

# Sample usage:
# echo "Average Count Hostname" && puppetdb_longest_queries.awk logs/puppetdb/puppetdb.log  | sort -rn | head | column -t

/command\ processed\ for/ {
  # Strip brackets from each log entry
  gsub(/[\[\]]/,"")
  # Store the cumulative total and count for each hostname in arrays
  name[$NF] += $5
  count[$NF] += 1
}

# Print the average, count, and hostname
END {
  for (n in name) print name[n] / count[n], count[n], n
}
