#!/usr/bin/env bash

#TODO: common.sh
warn() {
  printf '%s\n' "$@"
}

latest_logs() {
  while IFS= read -rd '' line; do
    _latest+=("${line#* }")
  done < <(find . -type f -name "$1*" -printf '%T@ %p\0' | sort -znr)

}

puppetserver_latest() {
  latest_logs "puppetserver-access"
  (( ${#_latest[@]} > 0 )) || {
    warn 'No puppetserver-access.log found.' 'Please run me from the root of an extracted support script'
    return
  }

  "$base_dir"/puppet-top-api-calls.sh -g "${_latest[0]}"
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
  )

  #TODO: function
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
