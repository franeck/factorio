#!/bin/bash

# Options.
BINDIR="/opt/factorio/bin"
CONFIGDIR="/opt/factorio/config"
DATADIR="/opt/factorio/data"
SAVEDIR="/opt/factorio/saves"
FACTORIO_RCON_PASSWORD=""
FACTORIO_RCON_PORT="27015"
# Set initial command
FACTORIO_CMD="${BINDIR}/x64/factorio"

# Setting rcon-port option
FACTORIO_CMD="$FACTORIO_CMD --rcon-port $FACTORIO_RCON_PORT"

# Setting rcon password option
if [ -z $FACTORIO_RCON_PASSWORD ]
  then
    FACTORIO_RCON_PASSWORD=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c16)
    echo "# RCON password is '$FACTORIO_RCON_PASSWORD'"
fi
FACTORIO_CMD="$FACTORIO_CMD --rcon-password $FACTORIO_RCON_PASSWORD"

# Copy example configs to default if they don't exist
if [ ! -f "${CONFIGDIR}/server-settings.json" ];
  then
    echo "# No server-settings.json found in ${CONFIGDIR}, copying from example"
    cp "${DATADIR}/server-settings.example.json" "${CONFIGDIR}/server-settings.json"
  else
    echo "# Using existing server-settings.json found in ${CONFIGDIR}"
fi
if [ ! -f "${CONFIGDIR}/map-gen-settings.json" ];
  then
    echo "# No map-gen-settings.json found in ${CONFIGDIR}, copying from example"
    cp "${DATADIR}/map-gen-settings.example.json" "${CONFIGDIR}/map-gen-settings.json"
  else
    echo "# Using existing map-gen-settings.json found in ${CONFIGDIR}"
fi

# Check for existing map / save.zip, use if found, generate new with settings if not.
if [ ! -f "${SAVEDIR}/save.zip" ];
  then
    echo "# Creating new map / save.zip in ${SAVEDIR} with settings from ${CONFIGDIR}/map-gen-settings.json"
    ${BINDIR}/x64/factorio --create save.zip --map-gen-settings /opt/factorio/config/map-gen-settings.json
  else
    echo "# Using latest map / save.zip found in ${SAVEDIR}"
fi

FACTORIO_CMD="$FACTORIO_CMD --start-server-load-latest --server-settings ${CONFIGDIR}/server-settings.json"

echo "# Launching Game"

# Closing stdin
exec 0<&-

exec $FACTORIO_CMD
