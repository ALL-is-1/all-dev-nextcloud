#!/bin/sh -e

# shellcheck source=src/redis/utilities/redis-utilities
. "$SNAP/utilities/redis-utilities"

# This is required by richdocuments so that it does not break installations.
# See https://github.com/nextcloud/richdocuments/issues/3780#issuecomment-2257677440
"$SNAP"/bin/redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" FLUSHDB
