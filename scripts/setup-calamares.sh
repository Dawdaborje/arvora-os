#!/usr/bin/env bash
# Compatibility shim — forwards to setup_calamares.sh
exec "$(dirname "$0")/setup_calamares.sh" "$@"
