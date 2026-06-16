#!/bin/bash

LOG_DIR="$(dirname "$0")/../logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/system_health.log"
JSON_FILE="$LOG_DIR/metrics.json"
ALERT_FILE="$LOG_DIR/alerts.log"
send_alert() {
  MESSAGE="$1"
  BOT_TOKEN="8802268156:AAEqGeqcRP4ZVSVSUXnquuKnwv-h1KKjdRs" 
  CHAT_ID="8532859860"

  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$MESSAGE" > /dev/null
}

# ---------------- SAFE METRICS ----------------
CPU=$(top -bn1 | awk '/Cpu/ {print 100 - $8}')
MEM=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
DISK=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

# SAFE DEFAULTS (IMPORTANT)
CPU=${CPU:-0}
MEM=${MEM:-0}
DISK=${DISK:-0}

# remove decimal issues
CPU=${CPU%.*}

# ---------------- STATUS ----------------
SYSTEM_STATUS="OK"

if [ "$CPU" -gt 80 ]; then
  SYSTEM_STATUS="CRITICAL"
elif [ "$CPU" -gt 50 ]; then
  SYSTEM_STATUS="WARN"
fi

if [ "$MEM" -gt 80 ]; then
  SYSTEM_STATUS="CRITICAL"
fi

if [ "$DISK" -gt 80 ]; then
  SYSTEM_STATUS="CRITICAL"
fi
if [ "$DISK" -gt 80 ]; then
  SYSTEM_STATUS="CRITICAL"
fi
SYSTEM_STATUS="CRITICAL"
if [ "$SYSTEM_STATUS" = "CRITICAL" ]; then
  send_alert "🚨 CRITICAL ALERT 🚨
CPU=$CPU%
MEM=$MEM%
DISK=$DISK%
STATUS=$SYSTEM_STATUS"
fi
# ---------------- ALERT LOG ----------------
if [ "$SYSTEM_STATUS" != "OK" ]; then
  echo "$(date) - $SYSTEM_STATUS - CPU:$CPU MEM:$MEM DISK:$DISK" >> "$ALERT_FILE"
fi

# ---------------- LOG FILE ----------------
{
echo "==== SYSTEM HEALTH REPORT ===="
echo "Date: $(date)"
echo "[CPU] $CPU% [$SYSTEM_STATUS]"
echo "[MEM] $MEM% [$SYSTEM_STATUS]"
echo "[DISK] $DISK% [$SYSTEM_STATUS]"
echo "System Status: $SYSTEM_STATUS"
echo "=============================="
} >> "$LOG_FILE"

# ---------------- JSON SAFE WRITE ----------------
if [ ! -f "$JSON_FILE" ]; then
  echo "[]" > "$JSON_FILE"
fi

TMP=$(mktemp)

jq ". + [{
  timestamp: $(date +%s),
  cpu: ($CPU|tonumber),
  memory: ($MEM|tonumber),
  disk: ($DISK|tonumber),
  status: \"$SYSTEM_STATUS\"
}]" "$JSON_FILE" > "$TMP" && mv "$TMP" "$JSON_FILE"

# ---------------- OUTPUT ----------------
echo "CPU=$CPU MEM=$MEM DISK=$DISK STATUS=$SYSTEM_STATUS"
