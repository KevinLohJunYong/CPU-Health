#!/bin/bash

top_n=${1:-3}
disk_to_check=${2:-'disk1'}
high_latency_threshold=${3:-100}
log_dir=${4:-'./logs'}

cpu_file="$log_dir/cpu_intensive_processes.txt"
memory_file="$log_dir/memory_intensive_processes.txt"
disk_file="$log_dir/disk_usage.txt"
io_file="$log_dir/io_statistics.txt"
load_file="$log_dir/cpu_load_average.txt"
ping_file="$log_dir/network_latency.txt"
traceroute_file="$log_dir/network_traceroute.txt"
netstat_file="$log_dir/active_network_connections.txt"
lsof_file="$log_dir/open_files_processes.txt"
vmstat_file="$log_dir/vmstat.txt"
error_log="$log_dir/error_log.txt"

mkdir -p "$log_dir"

write_error() {
    echo "$(date): $1" >> "$error_log"
}

execute_command() {
    bash -c "$1" > /dev/null 2>&1 || write_error "Failed to execute: $1"
}

execute_command "ps aux | awk '{print \$2, \$3, \$11}' | sort -k2 -nr | head -n $top_n > $cpu_file"
execute_command "ps aux | awk '{print \$2, \$4, \$11}' | sort -k2 -nr | head -n $top_n > $memory_file"
execute_command "df -h | grep '$disk_to_check' > $disk_file"
execute_command "iostat 1 2 | tail -n +3 > $io_file"
execute_command "uptime | cut -d ',' -f 3-5 > $load_file"
execute_command "ping -c 4 google.com > $ping_file 2>&1"
execute_command "traceroute 8.8.8.8 > $traceroute_file"
execute_command "netstat -p tcp -n > $netstat_file"
execute_command "lsof -nP | head -10 > $lsof_file"
execute_command "vm_stat -c 5 1 > $vmstat_file"
