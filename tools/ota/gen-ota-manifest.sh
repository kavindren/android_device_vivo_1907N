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
#
# NOTE: no `set -o pipefail` here on purpose - `unzip -p <big.zip> file | head` makes unzip
# take SIGPIPE and exit non-zero, which pipefail+`set -e` would turn into a silent abort.
set -eu

DIR="${1:?builds dir}"; BASE="${2:?public base url}"; OUT="${3:-$DIR/1907N.json}"
BASE="${BASE%/}"

command -v jq        >/dev/null || { echo "need: jq" >&2; exit 1; }
command -v unzip     >/dev/null || { echo "need: unzip" >&2; exit 1; }
command -v sha256sum >/dev/null || { echo "need: sha256sum" >&2; exit 1; }
mkdir -p "$(dirname "$OUT")"

entries='[]'
shopt -s nullglob
zips=("$DIR"/lineage-19.1-*-1907N*.zip)
[ "${#zips[@]}" -gt 0 ] || echo "warn: no lineage-19.1-*-1907N*.zip in $DIR (writing empty manifest)" >&2

for zip in "${zips[@]}"; do
    name="$(basename "$zip")"
    meta="$(unzip -p "$zip" META-INF/com/android/metadata 2>/dev/null || true)"
    ts="$(printf '%s\n' "$meta" | sed -n 's/^post-timestamp=//p' | head -1)"
    [ -n "$ts" ] || { echo "skip $name: no post-timestamp in metadata" >&2; continue; }

    bp="$(unzip -p "$zip" system/build.prop 2>/dev/null || true)"
    romtype="$(printf '%s\n' "$bp" | sed -n 's/^ro\.lineage\.releasetype=//p' | head -1)"
    romtype="${romtype:-unofficial}"
    ver="$(printf '%s\n' "$bp" | sed -n 's/^ro\.lineage\.build\.version=//p' | head -1)"
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
jq . "$OUT" >&2 || true
