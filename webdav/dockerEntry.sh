#!/bin/bash

echo ""
echo "$(date) Starting up"

# If apache have not run, assume first startup and fix  the
if ! (id docker &> /dev/null); then

	echo "User 'docker' not found in container so creating"

	# If "-e uid={custom/local user id}" flag is not set for "docker run" command, use /site/dav     owner as default
	DOCKER_UID=${uid:-$(stat -c "%u" /site/dav)}
	DOCKER_GID=${gid:-$(stat -c "%g" /site/dav)}

	echo "Docker UID : $DOCKER_UID, default = owner of /site/dav = $(stat -c "%u" /site/dav)"
	echo "Docker UID : $DOCKER_UID, default = owner of /site/dav = $(stat -c "%g" /site/dav)"

	#Create new docker group
	groupadd --non-unique --gid ${DOCKER_GID} docker

	# Create user called "docker" with selected UID
	useradd --shell /bin/bash \
	        --uid ${DOCKER_UID} \
	        --gid ${DOCKER_GID} \
	        --non-unique \
	        --comment "" \
	        --create-home \
	        docker
fi

rm -f /run/apache2/apache2.pid
#So find the username and groupname
echo "Running apache as $(id docker)"

#Execute the command
exec /usr/sbin/apachectl -D FOREGROUND