#!/usr/bin/env -S gawk -f

# Sample usage:
# echo "Average Count Hostname" && puppetserver_longest_compiles.awk logs/puppetserver/puppetserver.log | sort -rn | head | column -t

/Compiled (static )?catalog/ {
  # Store the cumulative total and count for each hostname in arrays
  name[$(NF - 6)] += $(NF-1)
  count[$(NF - 6)] += 1
}

END {
  for (n in name) print name[n] / count[n], count[n], n
}
