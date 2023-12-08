#!/bin/bash

echo "Top 3 CPU Intensive Processes:"
ps aux | awk '{print $2, $3, $11}' | sort -k2 -nr | head -3

echo ""
echo "Top 3 Memory Intensive Processes:"
ps aux | awk '{print $2, $4, $11}' | sort -k2 -nr | head -3