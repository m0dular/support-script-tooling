#!/usr/bin/env -S gawk -f

# Sample usage:
# gunzip -c enterprise/find/_opt_puppetlabs.txt.gz | dirs_largest.awk | sort -rn | head | numfmt --to=si
# Can be used with any of _etc_puppetlabs.txt.gz, _opt_puppetlabs.txt.gz, _var_log_puppetlabs.txt.gz

# For each regular file, i.e. the third column begins with '-'
$3 ~ /^-/ {
  # use the match() function to get the position of the filename 
  # i.e. a forward slash followed by anything other than a forward slash, then the end of the string
  m = match($11, /\/[^/]*$/)
  # add the byte size of the file ($7) to an associate array whose entry is the directory of the file
  # i.e. a substring of the file's full path from 0 to the beginning of the filename
  sizes[substr($11,0,m)]+=$7
}

END {
  for (s in sizes) print sizes[s]," ", s
}
