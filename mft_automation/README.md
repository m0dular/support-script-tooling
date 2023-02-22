#TODO: create a Bolt plan to automate this
## Prerequisites

* Install `git` and `bolt`
* Create the metrics_import directory in `root`'s home directory
```bash
mkdir metrics_import
```
* Clone operational dashboards to this directory
```bash
cd metrics_import
git clone https://github.com/puppetlabs/puppet_operational_dashboards.git
```

* Save files/metrics_import.sh to the `puppet_operational_dashboards` directory created by the `git clone`

## Set up InfluxDB and Grafana
* Run the `provision_dashboard` plan from `root`'s home directory
```bash
bolt plan run puppet_operational_dashboards::provision_dashboard --targets localhost
```

## Set up GPG key and passphrase
* Save the Support GPG key from 1pass to a file `key.asc`
* Import it
```bash
gpg --import key.asc
```
* Save the key's passphrase to a file `/root/.support_gpg`

## Set up the service to import metrics from sup scripts
* Save `files/metrics_import.service` to `/etc/systemd/system/metrics_import.service`
* Save `files/metrics_import.timer` to `/etc/systemd/system/metrics_import.timer`
* Do a daemon-reload
```bash
systemctl daemon-reload
```
* Confirm the timer is running
```bash
systemctl status metrics_import.timer
```
