#!/bin/bash
set -e

# If "-e uid={custom/local user id}" flag is not set for "docker run" command, use 9999 as default
CURRENT_UID=${uid:-$(stat -c "%u" /site/dav)}
CURRENT_GID=${gid:-$(stat -c "%g" /site/dav)}

echo "Current UID : $CURRENT_UID, default = owner of /site/dav = $(stat -c "%u" /site/dav)"
echo "Current UID : $CURRENT_UID, default = owner of /site/dav = $(stat -c "%g" /site/dav)"

groupadd --non-unique --gid ${CURRENT_GID} docker #Create it
# Create user called "docker" with selected UID
useradd --shell /bin/bash \
        --uid ${CURRENT_UID} \
        --gid ${CURRENT_GID} \
        --non-unique \
        --comment "" \
        --create-home \
        docker   || true

#So find the username and groupname
echo "Running apache as $(id docker)"

#Execute the command
exec $*