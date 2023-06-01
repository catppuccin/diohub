#!/usr/bin/env bash
#

__confirm_cmd() {
  command -v "$1" >/dev/null 2>&1 ||
    bake.die "Cannot find '$1' in path, confirm if it's exist"
  true
}

__parse_to_url() {
  local prefix="https://theme.felix.diohub"

  local -A parsed_text=()
  for s in "$@"; do
    parsed_text["${s%:*}"]="${s#*:}"
  done

  local url="$prefix?format_ver=0"
  for k in "${!parsed_text[@]}"; do
    local v="${parsed_text[$k]}"

    url+="&$k=ff$v"
  done

  echo "$url"
}

task.build() {
  __confirm_cmd jq

  local flavor="${1:?Error: expected flavor name!}"

  local -a parsed_json=()
  for json_k in $(jq --raw-output "keys[]" "flavors/$flavor.json"); do
    local json_v
    json_v="$(jq --raw-output '.["'"$json_k"'"]' "flavors/$flavor.json")"
    parsed_json+=("$json_k:$json_v")
  done

  __parse_to_url "${parsed_json[@]}"
}
