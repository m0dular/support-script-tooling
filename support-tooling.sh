#!/usr/bin/env bash

#TODO: common.sh
warn() {
  printf '%s\n' "$@"
}

latest_logs() {
  # Absolutely terrible hack because the dev is too lazy to deal with non-GNU utilities
  _latest=($(ls -t **/*"$1"*))
}

puppetserver_latest() {
  latest_logs "puppetserver-access"
  (( ${#_latest[@]} > 0 )) || {
    warn 'No puppetserver-access.log found.' 'Please run me from the root of an extracted support script'
    return
  }

  "$base_dir"/puppet-top-api-calls.sh -g "${_latest[0]}"
}

puppetserver_longest_borrows() {
  latest_logs "puppetserver-access"
  (( ${#_latest[@]} > 0 )) || {
    warn 'No puppetserver-access.log found.' 'Please run me from the root of an extracted support script'
    return
  }

  "$base_dir"/puppetserver_longest_borrows.awk "${_latest[0]}" | sort -nr | cut -f2- -d ' ' | head
}

puppetserver_largest_reports() {
  latest_logs "puppetserver-access"
  (( ${#_latest[@]} > 0 )) || {
    warn 'No puppetserver-access.log found.' 'Please run me from the root of an extracted support script'
    return
  }

  "$base_dir"/puppetserver_largest_reports.awk "${_latest[0]}" | sort -nr | cut -f2- -d ' ' | head
}

console_largest_facts() {
  latest_logs "console-services-api-access"
  (( ${#_latest[@]} > 0 )) || {
    warn 'No console-services-api-access.log found.' 'Please run me from the root of an extracted support script'
    return
  }

  "$base_dir"/console_largest_facts.awk "${_latest[0]}" | sort -nr | cut -f2- -d ' ' | head
}

confirm_opt() {
  cur_opt=$1
  cur_menu=("$@")
  cur_menu=("${cur_menu[@]:1}")

  [[ " ${cur_menu[@]} " =~ " $cur_opt " ]]
}

comm_cmds() {
  declare -A local menu=(
    ['Plot latest puppetserver-access.log']=puppetserver_latest
    ['Longest JRuby borrow times']=puppetserver_longest_borrows
    ['Largest report submissions']=puppetserver_largest_reports
    ['Largest fact sizes']=console_largest_facts
  )

  select opt in "${!menu[@]}"; do
    confirm_opt "$opt" "${!menu[@]}" || {
      warn 'Please enter a valid number'
      warn 'CTRL+C exits'
      break
    }
    "${menu[$opt]}"
    break
  done
}

shopt -s globstar nullglob
_tmp="$(mktemp)"

base_dir="${BASH_SOURCE[0]%/*}"
PS3="Select an option by number: "
declare -A main_menu=(
  ['Common commands']=comm_cmds
)

while :; do
  select opt in "${!main_menu[@]}"; do
    confirm_opt "$opt" "${!main_menu[@]}" || {
      warn 'Please enter a valid number'
      warn 'CTRL+C exits'
      break
    }
    "${main_menu[$opt]}"
    break
  done
done
