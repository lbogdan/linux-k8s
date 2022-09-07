#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

printf '[ ] something something '
sleep 2
# echo -e "\r[${GREEN}✓${NC}\n"
echo -e "\r[${RED}✕${NC}\n"
echo test
