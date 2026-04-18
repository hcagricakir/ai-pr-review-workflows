#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <rules-dir> <review-profile> <output-file> [extra-rules-path]"
  exit 1
fi

rules_dir="$1"
review_profile="$2"
output_file="$3"
extra_rules_path="${4:-}"

if [[ ! -f "${rules_dir}/common.md" ]]; then
  echo "Missing required rule file: ${rules_dir}/common.md"
  exit 1
fi

cat "${rules_dir}/common.md" > "${output_file}"

IFS='-' read -r -a profile_parts <<< "${review_profile}"
included_parts=" "

for part in "${profile_parts[@]}"; do
  if [[ -z "${part}" ]]; then
    continue
  fi

  case "${included_parts}" in
    *" ${part} "*) 
      continue
      ;;
  esac

  if [[ "${part}" == "common" ]]; then
    continue
  fi

  rule_file="${rules_dir}/${part}.md"
  if [[ ! -f "${rule_file}" ]]; then
    echo "Unsupported review profile component: ${part}"
    exit 1
  fi

  printf '\n\n' >> "${output_file}"
  cat "${rule_file}" >> "${output_file}"
  included_parts="${included_parts}${part} "
done

if [[ -n "${extra_rules_path}" ]]; then
  if [[ -f "${extra_rules_path}" ]]; then
    printf '\n\n' >> "${output_file}"
    cat "${extra_rules_path}" >> "${output_file}"
  else
    echo "Optional extra rules file not found, skipping: ${extra_rules_path}"
  fi
fi
