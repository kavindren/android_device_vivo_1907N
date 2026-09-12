#!/usr/bin/env bash
# Apply the vivo/1907N out-of-tree source patches (UDFPS HBM, Face Unlock, dual-Wi-Fi
# SoftAP, tethering regex, USB gadget bind, recovery backlight, LOS20 host-toolchain
# HOSTCFLAGS fix for kernel builds, LOS20 telephony-common gap fill).
#
# Run once after `repo sync`, from anywhere:
#     device/vivo/1907N/patches/apply-patches.sh
#
# Idempotent: patches already applied are skipped. A patch that neither applies clean nor
# reverse-applies is retried with `git apply --3way`; anything still failing is reported and
# makes the script exit non-zero.
#
# BASE is keyed by patch NAME (not repo path) - a repo can have more than one patch
# (frameworks/base currently has two, unrelated to each other).
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../../../.." && pwd)"      # .../device/vivo/1907N/patches -> source root
BASE_FILE="$HERE/BASE"

names=(frameworks_base packages_apps_Settings packages_modules_Connectivity \
       packages_modules_Wifi system_core bootable_recovery vendor_lineage sepolicy_vndr \
       frameworks_base_telephony_permissions)
paths=(frameworks/base packages/apps/Settings packages/modules/Connectivity \
       packages/modules/Wifi system/core bootable/recovery vendor/lineage \
       device/mediatek/sepolicy_vndr frameworks/base)

fail=0
for i in "${!names[@]}"; do
  name="${names[$i]}"; rel="${paths[$i]}"
  repo="$ROOT/$rel"; patch="$HERE/$name.patch"
  [ -f "$patch" ] || { echo "MISSING  $name.patch"; fail=1; continue; }
  [ -d "$repo/.git" ] || { echo "MISSING  repo $rel (run repo sync first)"; fail=1; continue; }

  if git -C "$repo" apply --check --reverse "$patch" >/dev/null 2>&1; then
    echo "SKIP     $name ($rel, already applied)"
    continue
  fi
  if git -C "$repo" apply --check "$patch" >/dev/null 2>&1; then
    git -C "$repo" apply "$patch" && echo "APPLIED  $name ($rel)" || { echo "ERROR    $name ($rel)"; fail=1; }
    continue
  fi
  if git -C "$repo" apply --3way "$patch" >/dev/null 2>&1; then
    echo "APPLIED  $name ($rel, 3-way)"
    continue
  fi
  echo "FAILED   $name ($rel) — base moved? expected $(grep "^$name " "$BASE_FILE" 2>/dev/null | awk '{print $2}' | cut -c1-10), got $(git -C "$repo" rev-parse --short HEAD)"
  fail=1
done

exit $fail
