#!/usr/bin/env -S gawk -f

# Sample usage:
# console_largest_facts.awk logs/puppetserver/puppetserver-access.log | sort -nr | cut -f2- -d ' ' | head

# We'll just use $NF for now for speed.
$7 ~ "classified/nodes" { print $NF " " $0 }
