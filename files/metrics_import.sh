#!/bin/bash
shopt -s nullglob

for f in /opt/mft-automations/puppet_enterprise_support*gz /opt/mft-automations/puppet_enterprise_support*gz.gpg; do
   # Does the file have a 5 digit ticket number after puppet_enterprise_support_
   has_ticket=$(echo "$f" | grep -Eo -- 'puppet_enterprise_support_[[:digit:]]{5}_')

   if ! [[ $has_ticket ]]; then
      echo "ERROR: no ticket ID found in $f"
      mv "$f" /opt/mft-automations/err
      continue
   fi

   if [[ "${f##*.}" == 'gpg' ]]; then
     # Decrypt the file to the same location as the source, stripping the .gpg suffix
     # Delete source file if it decrypts ok, otherwise move it to err/
     if cat /root/.support_gpg | gpg --pinentry-mode loopback --passphrase-fd 0 --batch --yes --output "${f%.*}" --decrypt "$f"; then
       rm -- "$f"
       f="${f%.*}"
     else
       echo "ERROR: failed to decrypt $f"
       mv "$f" /opt/mft-automations/err
       continue
     fi
   fi

   if ! tar tf "$f" | grep -q -m 1 'metrics\/.*json'; then
      echo "No metrics found in $f.  Skipping"
      rm -- "$f"
      continue
   fi

   # Strip the trailing _, then everything up to the last _ to get just the number
   ticket="${has_ticket%_}"
   ticket="${ticket##*_}"

   _tmp="$(mktemp)"
   /opt/puppetlabs/bolt/bin/bolt plan run puppet_operational_dashboards::load_metrics --targets localhost --run-as root influxdb_bucket="$ticket" support_script_file="$f" |& tee "$_tmp"

   if ! grep -q 'Wrote batch of [[:digit:]]* metrics' "$_tmp"; then
      echo "ERROR: failed to import metrics from $f"
      mv "$f" /opt/mft-automations/err
      continue
   fi

   rm -- "$_tmp"
   rm -- "$f"
done
