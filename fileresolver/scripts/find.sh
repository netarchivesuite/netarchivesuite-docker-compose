#!/usr/bin/env bash

##Note the use of the prefixed backslash to force locate to treat the expression as a glob
locate -b -d /db/db.db "\\"$1