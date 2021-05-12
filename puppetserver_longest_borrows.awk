#!/usr/bin/env -S gawk -f

# Sample usage:
# puppetserver_longest_borrows.awk logs/puppetserver/puppetserver-access.log | sort -nr | cut -f2- -d ' ' | head

BEGIN { FPAT="([^ ]+)|(\"[^\"]+\")" }

{ print $13 " " $0 }
