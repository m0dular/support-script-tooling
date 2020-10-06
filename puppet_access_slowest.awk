#!/usr/bin/env -S gawk -f

# Sample usage:
# puppet_access_slowest.awk logs/puppetserver/puppetserver-access.log | sort -nr | cut -f2- -d ' ' | head
# Can be used with any Puppet access log

BEGIN { FPAT="([^ ]+)|(\"[^\"]+\")" }

{ print $11 " " $0 }
