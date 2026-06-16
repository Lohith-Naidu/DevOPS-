#!/bin/bash

# =========================
# System Health Monitoring
# DevOps Bash Project
# =========================

echo "==== SYSTEM HEALTH REPORT ===="
echo "Date: $(date)"
echo ""

# -------------------------
# CPU Usage
# -------------------------
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU=${CPU%.*}

# -------------------------
# Memory Usage
# -------------------------
MEM=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')

# -------------------------
# Disk Usage
# -------------------------
DISK=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "CPU Usage: $CPU%"
echo "Memory Usage: $MEM%"
echo "Disk Usage: $DISK%"
echo ""

# -------------------------
# Health Logic
# -------------------------
STATUS="OK"

if [ "$CPU" -ge 80 ] || [ "$MEM" -ge 80 ] || [ "$DISK" -ge 80 ]; then
    STATUS="CRITICAL"
elif [ "$CPU" -ge 50 ] || [ "$MEM" -ge 50 ] || [ "$DISK" -ge 50 ]; then
    STATUS="WARN"
else
    STATUS="OK"
fi

echo "SYSTEM STATUS: $STATUS"

# -------------------------
# Logging
# -------------------------
LOG_DIR="/opt/devops-monitor/linux-scripts/logs"
mkdir -p $LOG_DIR

echo "$(date) CPU=$CPU MEM=$MEM DISK=$DISK STATUS=$STATUS" >> $LOG_DIR/system_health.log
