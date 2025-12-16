#!/bin/bash

# Load all packaging scripts

PACKAGING_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$PACKAGING_DIR/base.sh"
source "$PACKAGING_DIR/nix.sh"
