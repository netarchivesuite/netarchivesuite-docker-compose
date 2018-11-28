#!/bin/bash -e
# Adapted from https://github.com/tryolabs/nginx-docker/blob/master/docker-entrypoint.sh
for f in $(find /nas -type f -name "*.j2"); do
    echo -e "Evaluating template\n\tSource: $f\n\tDest: ${f%.j2}"
    j2 $f > ${f%.j2}
    rm -f $f
done
chmod 755 /nas/start.sh
/nas/start.sh
