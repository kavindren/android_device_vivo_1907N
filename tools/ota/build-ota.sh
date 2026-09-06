#!/usr/bin/env bash
# Build a release OTA zip for 1907N with a correct, monotonic post-timestamp.
#
#   device/vivo/1907N/tools/ota/build-ota.sh [--sync-to user@host:/srv/ota]
#
# Why this exists: buildinfo.prop (which holds ro.build.date / ro.build.date.utc /
# ro.build.version.incremental) lists build_date.txt and build_number.txt as *order-only*
# prerequisites (build/make/core/sysprop.mk). On an incremental build those files get a
# fresh value but do NOT retrigger buildinfo.prop, so ro.build.date.utc — and therefore the
# OTA post-timestamp — stays frozen at whatever it was when buildinfo.prop last rebuilt.
# The LineageOS Updater hides an update whose post-timestamp is not strictly greater than the
# installed build's ro.build.date.utc, so a stale timestamp = "no update ever shows".
# Deleting buildinfo.prop (and the staged build.prop / target-files) forces it regenerated
# against the current build_date.txt.
set -eu

SYNC_DEST=""
[ "${1:-}" = "--sync-to" ] && { SYNC_DEST="${2:?--sync-to needs user@host:/path}"; shift 2; }

TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$TOP"
OUT=out/target/product/1907N

# envsetup.sh defines `mka`/`lunch` as shell functions, which a child script process does not
# inherit - so source it here unconditionally rather than trusting a parent shell. envsetup and
# lunch are noisy with unset vars / non-zero returns, so relax the shell around them.
set +eu
source build/envsetup.sh
lunch lineage_1907N-userdebug
set -eu

echo ">> clearing frozen build.prop / buildinfo.prop / target-files"
find "$OUT" -name buildinfo.prop -delete 2>/dev/null || true
rm -f  "$OUT"/system/build.prop "$OUT"/*/build.prop "$OUT"/*/etc/build.prop \
       "$OUT"/system/*/etc/build.prop \
       "$OUT"/obj/ETC/*build_prop*/build.prop \
       "$OUT"/system.img "$OUT"/vendor.img \
       "$OUT"/lineage_1907N-ota-*.zip "$OUT"/lineage-19.1-*-1907N.zip
rm -rf "$OUT"/obj/PACKAGING/target_files_intermediates

echo ">> mka bacon"
mka bacon

ZIP="$(ls -t "$OUT"/lineage-19.1-*-1907N*.zip | head -1)"
TS="$(unzip -p "$ZIP" META-INF/com/android/metadata | sed -n 's/^post-timestamp=//p')"
echo
echo ">> $ZIP"
echo ">> post-timestamp = $TS  ($(date -d "@$TS"))"

if [ -n "$SYNC_DEST" ]; then
    echo ">> scp -> $SYNC_DEST/builds/"
    scp "$ZIP" "$SYNC_DEST/builds/"
    echo ">> now regenerate the manifest on the server, e.g.:"
    echo "   gen-ota-manifest.sh /srv/ota/builds https://95.165.95.207.sslip.io/builds /srv/ota/api/v1/1907N.json"
fi
