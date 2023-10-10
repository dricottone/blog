#!/bin/bash

API_PASSWD="$(cat bsky-passwd)"

DID_HANDLE='handle=dricottone.bsky.social'
DID_URI='https://bsky.social/xrpc/com.atproto.identity.resolveHandle'
DID="$(curl --get --no-progress-meter --data-urlencode "$DID_HANDLE" "$DID_URI" | jq --raw-output '.did')"

APIKEY_URI='https://bsky.social/xrpc/com.atproto.server.createSession'
APIKEY_HEADER='Content-Type: application/json'
APIKEY_DATA="{ \"identifier\": \"$DID\", \"password\": \"$API_PASSWD\" }"
APIKEY="$(curl -X POST --no-progress-meter --header "$APIKEY_HEADER" --data "$APIKEY_DATA" "$APIKEY_URI" | jq --raw-output '.accessJwt')"

FEED_URI='https://bsky.social/xrpc/app.bsky.feed.getAuthorFeed'
FEED_HEADER="Authorization: Bearer $APIKEY"
FEED_ACTOR="actor=$DID"
FEED_LIMIT='limit=3'
FEED="$(curl --get --no-progress-meter --header "$FEED_HEADER" --data-urlencode "$FEED_ACTOR" --data-urlencode "$FEED_LIMIT" "$FEED_URI" | jq --raw-output .feed)"

echo "<ul>"
echo "  <li>"
echo "${FEED}" | jq --raw-output '.[0].post.record.text' | sed -e 's/.*/    <p>&<\/p>/'
echo "  </li>"
echo "  <li>"
echo "${FEED}" | jq --raw-output '.[1].post.record.text' | sed -e 's/.*/    <p>&<\/p>/'
echo "  </li>"
echo "  <li>"
echo "${FEED}" | jq --raw-output '.[2].post.record.text' | sed -e 's/.*/    <p>&<\/p>/'
echo "  </li>"
echo "</ul>"

