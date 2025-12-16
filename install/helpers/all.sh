#!/bin/bash

# Load all helper functions

HELPERS_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$HELPERS_DIR/functions.sh"

log_info "Helper functions loaded"
