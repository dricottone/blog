#!/bin/sh

PASSWD="$(cat lastfm-passwd)"

USER="al__dente"
URI="https://ws.audioscrobbler.com/2.0/?method=user.gettoptracks&user=${USER}&api_key=${PASSWD}&format=json&period=1month&limit=5"
FEED="$(curl --get --no-progress-meter "$URI" | jq --raw-output '[.toptracks.track[] | {track: .name, artist: .artist.name}]')"

echo "<ol>"
echo "${FEED}" | jq --raw-output '.[0] | "  <li>\(.track) by \(.artist)</li>"'
echo "${FEED}" | jq --raw-output '.[1] | "  <li>\(.track) by \(.artist)</li>"'
echo "${FEED}" | jq --raw-output '.[2] | "  <li>\(.track) by \(.artist)</li>"'
echo "${FEED}" | jq --raw-output '.[3] | "  <li>\(.track) by \(.artist)</li>"'
echo "${FEED}" | jq --raw-output '.[4] | "  <li>\(.track) by \(.artist)</li>"'
echo "</ol>"

