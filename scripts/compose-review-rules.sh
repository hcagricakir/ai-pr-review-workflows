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
profile_dir="${rules_dir}/profiles"

declare -a included_files=()

append_file() {
  local file="$1"

  if [[ ! -f "${file}" ]]; then
    echo "Missing rule file: ${file}"
    exit 1
  fi

  for included in "${included_files[@]-}"; do
    if [[ "${included}" == "${file}" ]]; then
      return
    fi
  done

  if [[ -s "${output_file}" ]]; then
    printf '\n\n' >> "${output_file}"
  fi

  cat "${file}" >> "${output_file}"
  included_files+=("${file}")
  echo "Included rule file: ${file}"
}

append_manifest_file() {
  local manifest_file="$1"
  local entry

  while IFS= read -r entry || [[ -n "${entry}" ]]; do
    [[ -z "${entry}" ]] && continue
    [[ "${entry}" == \#* ]] && continue
    append_file "${rules_dir}/${entry%.md}.md"
  done < "${manifest_file}"
}

append_profile_rules() {
  local manifest_file="${profile_dir}/${review_profile}.txt"

  if [[ -f "${manifest_file}" ]]; then
    append_manifest_file "${manifest_file}"
    return
  fi

  local part
  IFS='-' read -r -a profile_parts <<< "${review_profile}"
  for part in "${profile_parts[@]}"; do
    [[ -z "${part}" ]] && continue
    [[ "${part}" == "common" || "${part}" == "reviewer-output" ]] && continue
    append_file "${rules_dir}/${part}.md"
  done
}

append_extra_rules() {
  local path="$1"

  if [[ -z "${path}" ]]; then
    return
  fi

  if [[ -f "${path}" ]]; then
    append_file "${path}"
    return
  fi

  if [[ -d "${path}" ]]; then
    local file_count=0
    local file
    while IFS= read -r file; do
      append_file "${file}"
      file_count=$((file_count + 1))
    done < <(find "${path}" -maxdepth 1 -type f -name '*.md' | sort)

    if [[ "${file_count}" -eq 0 ]]; then
      echo "No markdown rule files found in optional extra rules directory, skipping: ${path}"
    fi
    return
  fi

  echo "Optional extra rules path not found, skipping: ${path}"
}

: > "${output_file}"

append_file "${rules_dir}/reviewer-output.md"
append_file "${rules_dir}/common.md"
append_profile_rules
append_extra_rules "${extra_rules_path}"
