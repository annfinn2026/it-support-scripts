#!/bin/bash
# ==============================================================================
# System Health Check Script for Linux / Home Lab Servers
# Author: Hans Annfinn Johannesen
# ==============================================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   Linux Server Health & Diagnostic Status          ${NC}"
echo -e "${CYAN}====================================================${NC}"

# 1. Hukommelsesforbrug (RAM)
echo -e "\n${YELLOW}[1] RAM Forbrug:${NC}"
free -h | awk 'NR==2{printf "   Brugt: %s / Total: %s (%.2f%%)\n", $3, $2, $3/$2*100}'

# 2. Diskplads
echo -e "\n${YELLOW}[2] Diskplads (/ root partition):${NC}"
df -h / | awk 'NR==2{printf "   Brugt: %s / Total: %s (%s)\n", $3, $2, $5}'

# 3. ZFS Pool Status (hvis tilgængelig)
if command -v zpool &> /dev/null; then
    echo -e "\n${YELLOW}[3] ZFS Pool Status:${NC}"
    zpool list | awk 'NR>1{printf "   Pool: %s | Status: %s | Brugt: %s\n", $1, $10, $5}'
fi

# 4. Aktive Docker Containers (hvis tilgængelig)
if command -v docker &> /dev/null; then
    echo -e "\n${YELLOW}[4] Docker Status:${NC}"
    RUNNING_CONTAINERS=$(docker ps -q | wc -l)
    echo -e "   Kørende containers: ${GREEN}${RUNNING_CONTAINERS}${NC}"
fi

# 5. Netværksgateway tjek
echo -e "\n${YELLOW}[5] Netværkstest (Gateway / DNS):${NC}"
if ping -c 1 1.1.1.1 &> /dev/null; then
    echo -e "   ✔ Internetforbindelse (1.1.1.1): ${GREEN}ONLINE${NC}"
else
    echo -e "   ✖ Internetforbindelse: ${RED}OFFLINE${NC}"
fi

echo -e "\n${CYAN}====================================================${NC}"
