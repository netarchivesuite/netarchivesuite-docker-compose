#!/bin/bash
# wait-for-postgres.sh

set -e

host="$1"
shift
cmd="$@"

until PGPASSWORD=devel123 psql -h "$host" -U "devel" -d "admindb" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

>&2 echo "Postgres is up - executing command"
exec $cmd