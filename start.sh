#!/usr/bin/bash

[[ -f "/var/lib/plex/Plex Media Server/plexmediaserver.pid" ]] &&
    rm "/var/lib/plex/Plex Media Server/plexmediaserver.pid"

echo "Starting Plex Media Server..."
"/usr/lib/plexmediaserver/Plex Media Server"
