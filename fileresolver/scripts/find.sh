#!/usr/bin/env bash
echo "Script got $1" >&2
locate --regex --limit 0 --basename -d /db/db.db $1