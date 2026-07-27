#!/usr/bin/env bash
# ==============================================================================
# Script: esphome_ha_backup.sh
# Beskrivelse: Automatiseret backup af Home Automation & ESP32/ESP8266 board-konfigurationer.
# Forfatter: Hans Annfinn Johannesen (annfinn2026)
# Brugerkontekst: Home Assistant, ESPHome node YAMLs, automations & sensor data.
# ==============================================================================

set -euo pipefail

# Konfiguration
BACKUP_DIR="${BACKUP_DIR:-/var/backups/home_automation}"
CONFIG_SOURCE="${CONFIG_SOURCE:-/config}"
ESPHOME_DIR="${CONFIG_SOURCE}/esphome"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/esphome_ha_backup_${TIMESTAMP}.tar.gz"

# Farvekoder til konsol
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   HOME AUTOMATION & ESP BOARD BACKUP SCRIPT         ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Klargør backup-mappe
if [ ! -d "${BACKUP_DIR}" ]; then
    echo -e "${YELLOW}[!] Opretter backup-mappe: ${BACKUP_DIR}${NC}"
    mkdir -p "${BACKUP_DIR}"
fi

# 2. Kontrollér konfigurationskilder
echo -e "${GREEN}[+] Tjekker kildedirektiver...${NC}"
if [ -d "${ESPHOME_DIR}" ]; then
    echo -e "    * ESPHome boards YAML dir fundet: ${ESPHOME_DIR}"
else
    echo -e "    * ESPHome dir ikke fundet på standardsti, laver backup af tilgængelige YAMLs."
fi

# 3. Eksekver komprimeret arkivering
echo -e "${GREEN}[+] Genererer sikkerhedskopi arkiv...${NC}"

tar -czf "${BACKUP_FILE}" \
    --exclude="*.log" \
    --exclude="*.db-wal" \
    --exclude="*.db-shm" \
    --exclude="home-assistant_v2.db" \
    --exclude=".cloud" \
    --exclude="deps" \
    --exclude="__pycache__" \
    "${CONFIG_SOURCE}/configuration.yaml" \
    "${CONFIG_SOURCE}/automations.yaml" \
    "${CONFIG_SOURCE}/scripts.yaml" \
    "${CONFIG_SOURCE}/scenes.yaml" \
    "${CONFIG_SOURCE}/secrets.yaml" \
    "${ESPHOME_DIR}" 2>/dev/null || true

if [ -f "${BACKUP_FILE}" ]; then
    FILE_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo -e "${GREEN}[SUCCESS] Backup gennemført! Arkiv: ${BACKUP_FILE} (${FILE_SIZE})${NC}"
else
    echo -e "${RED}[ERROR] Backup mislykkedes! Arkiv blev ikke oprettet.${NC}"
    exit 1
fi

# 4. Automatisk rotation (Ryd op i gamle backups)
echo -e "${GREEN}[+] Renser arkiv for backups ældre end ${RETENTION_DAYS} dage...${NC}"
DELETED_COUNT=$(find "${BACKUP_DIR}" -name "esphome_ha_backup_*.tar.gz" -type f -mtime +"${RETENTION_DAYS}" -delete -print | wc -l)
echo -e "    * Slettede ${DELETED_COUNT} forældede backup-filer."

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   BACKUP PROCES AFSLUTTET SIKKERT                 ${NC}"
echo -e "${BLUE}====================================================${NC}"
