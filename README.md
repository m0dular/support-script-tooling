# support-script-tooling

## Requirements
* mlr
* gawk
* gnuplot
* bash 4+

Note for MacOS users: to get a recent enough version of `bash`, you will need to manually install it, e.g.

```
brew install bash
```

Then confirm the version with

```
/usr/bin/env bash --version
```

See issue #13 if you have suggetions to improve this.

For convenience, you may want to add this repo to `$PATH` instead of using absolute paths.

Below is a brief description of each job.

### support-tooling.sh
An interactive wrapper script for some of the more common/useful things you can do with this repo.  Run `support-tooling.sh` from within an extracted support script and a simple menu will guide the user.

### puppet-top-api-calls.sh

Summarize the count, average duration, and 99th percentile duration of per endpoint in Puppet server and DB access logs per 30 minute interval.  Can also graph the count and average duration in `gnuplot`

```
top-api-calls.sh [-b] [-g] [-c] <access_files>
  -b uses the JRuby borrow time instead of overall duration
  -g plots the average durations in gnuplot
     -c can be used in combination with -g to plot counts
```

### herd_plot.sh

```
herd_plot.sh <herd_query_file>
```

Plots the results of the thundering herd query in gnuplot.
TODO: summarize the data so it's more legible


### partition_sum.sh

```
partition_sum.sh [ -t <partition name> ] <path_to_db_relation_sizes_by_table.txt>
```

Outputs the total size of a partitioned postgres table, defaulting to `resource_events`.  Currently, `-t pe-puppetdb.reports` is also supported.

```
$ partition_sum.sh -t pe-puppetdb.reports resources/db_relation_sizes_by_table.txt  | numfmt --to=si
29G
```

### puppet_access_longest.awk and puppet_access_slowest.awk

```
puppet_access_slowest.awk <path_to_access_log>
```

Prepend the desired field from the access logs (currently, `%b` for byte size of the payload and `%D` for the duration) to each line.  Can be used in combination with other tools, e.g.

```
puppet_access_slowest.awk logs/puppetserver/puppetserver-access.log | sort -nr | cut -f2- -d ' ' | head
```

### puppetdb_longest_queries.awk

```
puppetdb_longest_queries.awk <path_to_puppetdb.log>
```

Calculate the average duration of a PDB command per node. Can be used in combination with other tools, e.g.

```
echo "Average Count Hostname" && puppetdb_longest_queries.awk logs/puppetdb/puppetdb.log  | sort -rn | head | column -t
```

### puppetserver_longest_compiles.awk

Calculates the average catalog compilation time per node.  Can be used in combination with other tools, e.g.

```
echo "Average Count Hostname" && puppetserver_longest_compiles.awk logs/puppetserver/puppetserver.log | sort -rn | head | column -t
```
