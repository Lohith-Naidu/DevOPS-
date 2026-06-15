#!/bin/bash

echo "===== SYSTEM HEALTH REPORT ====="

echo ""
echo "Hostname:"
hostname

echo ""
echo "Uptime:"
uptime

echo ""
echo "Memory Usage:"
free -h

echo ""
echo "Disk Usage:"
df -h

echo ""
echo "===== REPORT COMPLETE ====="