#!/usr/bin/env bash
# Generate a LineageOS Updater v1 manifest for self-hosted OTA.
#
#   gen-ota-manifest.sh <builds-dir> <public-base-url> [out.json]
#
# <builds-dir>       directory containing lineage-19.1-*-1907N*.zip
# <public-base-url>  where the zips are served, e.g. https://ota.example.com/builds
# out.json          default: <builds-dir>/1907N.json
#
# Needs: unzip, sha256sum, stat, jq.  Run it after every `mka bacon`.
set -euo pipefail

DIR="${1:?builds dir}"; BASE="${2:?public base url}"; OUT="${3:-$DIR/1907N.json}"
BASE="${BASE%/}"

entries='[]'
shopt -s nullglob
for zip in "$DIR"/lineage-19.1-*-1907N*.zip; do
    name="$(basename "$zip")"
    meta="$(unzip -p "$zip" META-INF/com/android/metadata 2>/dev/null || true)"
    ts="$(sed -n 's/^post-timestamp=//p' <<<"$meta")"
    [ -n "$ts" ] || { echo "skip $name: no post-timestamp in metadata" >&2; continue; }

    # romtype must equal ro.lineage.releasetype of the running build (case-insensitive)
    romtype="$(unzip -p "$zip" system/build.prop 2>/dev/null \
                | sed -n 's/^ro\.lineage\.releasetype=//p' | head -1)"
    romtype="${romtype:-unofficial}"
    ver="$(unzip -p "$zip" system/build.prop 2>/dev/null \
            | sed -n 's/^ro\.lineage\.build\.version=//p' | head -1)"
    ver="${ver:-19.1}"

    id="$(sha256sum "$zip" | cut -d' ' -f1)"
    size="$(stat -c%s "$zip")"

    entries="$(jq -c \
        --arg fn "$name" --arg id "$id" --arg rt "$romtype" \
        --arg url "$BASE/$name" --arg ver "$ver" \
        --argjson ts "$ts" --argjson sz "$size" \
        '. + [{datetime:$ts, filename:$fn, id:$id, romtype:$rt, size:$sz, url:$url, version:$ver}]' \
        <<<"$entries")"
    echo "added $name  (ts=$ts type=$romtype ver=$ver)" >&2
done

jq -n --argjson r "$(jq -c 'sort_by(.datetime)' <<<"$entries")" '{response:$r}' > "$OUT"
echo "wrote $OUT" >&2
