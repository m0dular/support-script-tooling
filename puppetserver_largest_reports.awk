#!/usr/bin/env -S gawk -f

# Sample usage:
# puppetserver_largest_reports.awk logs/puppetserver/puppetserver-access.log | sort -nr | cut -f2- -d ' ' | head

BEGIN { FPAT="([^ ]+)|(\"[^\"]+\")" }

$6 ~ "/report" { print $12 " " $0 }
