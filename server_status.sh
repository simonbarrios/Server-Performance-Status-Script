#!/bin/bash
# server_status.sh
# A Script to display key system metrics (CPU, Memory, Disk) and top processes.
#
#
# --- SCRIPT PRIVILEGE CHECK ---
# Ensure the script is run with root privileges (EUID 0)
if [[ $EUID -ne 0 ]]; then
	echo "Error: This script must be run as root or with the 'sudo' command."
	exit 1
fi
#-------------------------------------------------------------------------------

# --- Configuration ---
# # Set the scale for 'bc' for floating point math
BC_SCALE=2
# Define the root filesystem path to check
DISK_PATH="/"

# --- Function Definition ---
#
# Function to safely calculate percentages using 'bc'
calculate_percent() {
	local used=$1
	local total=$2

	# We check if total is empty OR if 'bc' evaluates it to zero.
	if [ -z "$total" ] || [ "$(echo "$total == 0" | bc -l)" -eq 1 ]; then
		echo "0.00"
	else
		echo "scale=$BC_SCALE; ($used / $total) * 100" | bc -l
	fi
}

# 1. Total CPU Usage
echo "========================================================================="
echo "	      SYSTEM RESOURCE MONITOR - $(date +'%Y-%m-%d %H:%M:%S')"
echo "========================================================================="
echo -e "\n--- 1. Total CPU Usage ---"

# Get the idle percentage from 'top' and calculate usage (100 - Idle)
CPU_IDLE_PERCENT=$(LC_ALL=C top -bn1 2>/dev/null | grep "Cpu(s)" |  awk '{print $8}')

if [ -z "$CPU_IDLE_PERCENT" ]; then
	echo "CPU data could not be retrieved."
else
	# Use bc to calculate 100 - Idle
	CPU_USAGE=$(echo "scale=$BC_SCALE; 100 - $CPU_IDLE_PERCENT" | bc -l)
	echo "Total CPU Usage: ${CPU_USAGE}%"
fi

# 2. Total Memory Usage
echo -e "\n--- 2. Total Memory Usage (MB) ---"
# We read the values directly into variables
read -r TOTAL_MEM USED_MEM FREE_MEM <<< $(free -m | awk '/Mem/ {print $2, $3, $4}')

MEM_PERCENT=$(calculate_percent "$USED_MEM" "$TOTAL_MEM")

printf "Total:%10s MB\n" "$TOTAL_MEM"
printf "Used: %10s MB (%s%%)\n" "$USED_MEM" "$MEM_PERCENT"
printf "Free: %10s MB\n" "$FREE_MEM"

# 3,Total Disk Usage (Focus on root filesystem)
echo -e "\n--- 3. Total Disk Usage ($DISK_PATH) ---"
# Using 'df -h' to het human readable sizes, and tail -n 1 to get the data line
DISK_DATA=$(df -h $DISK_PATH | tail -n 1)

if [ -z "$DISK_PATH" ]; then
	echo "Disk data for $DISK_PATH could not be retrieved."
else
	DISK_SIZE=$(echo $DISK_DATA | awk '{print $2}')
	DISK_USED_HUMAN=$(echo $DISK_DATA | awk '{print $3}')
        DISK_FREE_HUMAN=$(echo $DISK_DATA | awk '{print $4}')
 	DISK_PERCENT=$(echo $DISK_DATA | awk '{print $5}')

	printf "Filesystem Size: %10s\n" "$DISK_SIZE"
	printf "Used: 		 %10s (%s)\n" "$DISK_USED_HUMAN" "$DISK_PERCENT"
	printf "Free: 		 %10s\n" "$DISK_FREE_HUMAN"
fi

# 4. Top 5 Processes by CPU Usage
echo -e "\n--- 4. Top 5 Processes by CPU Usage ---"
# ps aux: standard process listing
# --sort=-%cpu: sort by CPU usage descending
# head -n 6: get header line + top 5 (including header row)
ps aux --sort=-%cpu | head -n 6

# 5. Top 5 Processes by Memory Usage
echo -e "\n--- 5. Top 5 Processes by Memory Usage ---"
# ps aux: standard process listing
# --sort=-%mem: sort by memory usage descending
# head -n 6: get header line + top 5 (including header row)
ps aux --sort=-%mem | head -n 6

echo "========================================================================="
