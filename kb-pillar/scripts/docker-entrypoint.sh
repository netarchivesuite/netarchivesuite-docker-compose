#!/usr/bin/env bash
##RUN_AS_ROOT=yes /kb-pillar/bin/kb-pillar  start
mkdir -p /netarkivet/001
mkdir -p /netarkivet/002
mkdir -p /netarkivet/003

exec "$@"