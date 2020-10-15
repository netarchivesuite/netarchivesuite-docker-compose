#!/usr/bin/env bash

set -e

container="$1"
shift
cmd="$@"
echo "cmd = $cmd"

# Wait on exit by pinging container
while ping -c1 ${container} &>/dev/null; do
    sleep 5
done

echo "$container finished! - executing command"
exec $cmd