#!/bin/bash

set -e

# we get rid of most of the steps from here:
# https://github.com/maxking/docker-mailman/blob/main/core/docker-entrypoint.sh
# leaving just the last few lines:

# mailman seems to need it?
apk add postfix

# Now chown the places where mailman wants to write stuff.
chown -R mailman /mailman

# Generate the LMTP files for postfix if needed.
su-exec mailman mailman aliases

exec su-exec mailman master
