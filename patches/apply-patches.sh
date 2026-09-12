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

# --- Non-patch fixups ---

# LOS20 kernel build with the newer bundled clang needs a newer aarch64 assembler than the
# one bundled in prebuilts/gcc's ancient aarch64-linux-android-4.9 toolchain (see
# BoardConfig.mk). This isn't representable as a normal git patch (binary file swapped for a
# script), so it's done here directly. Requires extra/aarch64-linux-gnu-binutils (pacman on
# Arch; install the equivalent package for your distro if this fails).
AS_DIR="$ROOT/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin"
AS_REAL="$AS_DIR/aarch64-linux-android-as"
if [ -d "$AS_DIR" ]; then
  if [ -f "$AS_REAL.real" ]; then
    echo "SKIP     aarch64-linux-android-as wrapper (already installed)"
  else
    if [ ! -x /usr/bin/aarch64-linux-gnu-as ]; then
      echo "MISSING  /usr/bin/aarch64-linux-gnu-as - install aarch64-linux-gnu-binutils (or equivalent) first"
      fail=1
    else
      cp "$AS_REAL" "$AS_REAL.real"
      cp "$HERE/aarch64-linux-android-as.wrapper.sh" "$AS_REAL"
      chmod +x "$AS_REAL"
      echo "APPLIED  aarch64-linux-android-as wrapper"
    fi
  fi
else
  echo "MISSING  $AS_DIR (run repo sync first)"
  fail=1
fi

exit $fail
