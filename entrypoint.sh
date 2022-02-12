#!/bin/bash
# Docker entrypoint script.

/app/bin/my_app eval "Shlinkedin.Release.migrate"

exec $@
