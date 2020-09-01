#!/usr/bin/env bash

docker-compose -f docker-compose.yml -f docker-compose-bitmag.yml -f docker-compose-wrs.yml up  --build --force-recreate
