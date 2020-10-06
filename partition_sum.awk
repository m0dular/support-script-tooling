#!/usr/bin/env -S gawk -f

# Run via partition_sum.sh

{
  gsub(/\ /,""); gsub(/bytes/, "", $NF); gsub(/kB/, "K", $NF); gsub(/MB/, "M", $NF); gsub(/GB/, "G", $NF)
}
$1 ~ table {
  cmd = "echo " $NF "| numfmt --from=auto"; while ( ( cmd | getline result) > 0) sum += result
}
END { print sum }
