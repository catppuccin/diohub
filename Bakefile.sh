#!/usr/bin/env bash
#

__ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 ||
    bake.die "Cannot find '$1' in path, ensure if it's installed"
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

  printf "%s\n" "$url"
}

__build() {
  __ensure_cmd jq

  local flavor="$1"
  [[ -z "$flavor" ]] && bake.die "\$1: Specify at least one flavor"

  local -a parsed_json=()
  for json_k in $(jq --raw-output "keys[]" "flavors/$flavor.json"); do
    [[ "$json_k" = "accent" ]] && continue
    local json_v
    json_v="$(jq --raw-output '.["'"$json_k"'"]' "flavors/$flavor.json")"
    parsed_json+=("$json_k:${json_v#'#'}")
  done

  for i in $(jq --raw-output ".accent | keys[]" "flavors/$flavor.json"); do
    local accent_v accent_k
    accent_k="$(jq --raw-output ".accent[$i][0]" "flavors/$flavor.json")"
    accent_v="$(jq --raw-output ".accent[$i][1]" "flavors/$flavor.json")"

    parsed_json+=("accent:${accent_v#'#'}")
    printf "\x1b[1m%s\x1b[0m\n" "$accent_k"
    __parse_to_url "${parsed_json[@]}"
  done
}

task.build-url() {
  __build "$@"
}


task.build-md() {
  local flavor="$1"
  [[ -z "$flavor" ]] && bake.die "\$1: Specify at least one flavor"

  local -a accent_name=()
  local -a urls=()
  local i=0
  for l in $(__build "$1"); do
    if (( ! i )); then
      : "$(sed -E $'s/\e\\[[0-9]m//g' <<< "$l")"
      accent_name+=("$_")
      i=1
    else
      urls+=("$l")
      i=0
    fi
  done

  for k in "${!urls[@]}"; do
    local url="${urls[$k]}" name="${accent_name[$k]}"
    printf -- '- **<a href="%s"><img alt="%s" src="https://github.com/catppuccin/catppuccin/raw/main/assets/palette/circles/%s.png" height="12" width="12" />%s</a>**\n' \
      "$url" "${flavor^} $name" "${flavor}_${name,,}" "$name"
  done
}
