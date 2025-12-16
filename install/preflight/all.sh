#!/bin/bash

# Load all preflight scripts

PREFLIGHT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$PREFLIGHT_DIR/checks.sh"
