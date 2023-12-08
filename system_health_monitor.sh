
#!/bin/bash

top_n=3
disk_to_check='disk1'
network_interface='en0'
high_cpu_threshold=80.0
high_memory_threshold=80.0
high_latency_threshold=100

cpu_file="cpu_intensive_processes.txt"
memory_file="memory_intensive_processes.txt"
disk_file="disk_usage.txt"
load_file="cpu_load_average.txt"
ping_file="network_latency.txt"
traceroute_file="network_traceroute.txt"
netstat_file="active_network_connections.txt"
lsof_file="open_files_processes.txt"
vmstat_file="vmstat.txt"

echo "Timestamp: $(date)" > "$cpu_file"
echo "Top $top_n CPU Intensive Processes:" >> "$cpu_file"
ps aux | awk '{print $2, $3, $11}' | sort -k2 -nr | head -$top_n >> "$cpu_file"

echo "Timestamp: $(date)" > "$memory_file"
echo "Top $top_n Memory Intensive Processes:" >> "$memory_file"
ps aux | awk '{print $2, $4, $11}' | sort -k2 -nr | head -$top_n >> "$memory_file"

echo "Timestamp: $(date)" > "$disk_file"
echo "Disk Usage for $disk_to_check:" >> "$disk_file"
df -h | grep "$disk_to_check" >> "$disk_file"

echo "Timestamp: $(date)" > "$load_file"
echo "CPU Load Average:" >> "$load_file"
uptime | cut -d ',' -f 3-5 >> "$load_file"

echo "Timestamp: $(date)" > "$ping_file"
echo "Checking Network Latency to Google DNS:" >> "$ping_file"
ping -c 4 google.com >> "$ping_file" 2>&1

latency=$(tail -n 1 "$ping_file" | awk -F '/' '{print $5}')
if [[ $latency =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    latency=${latency%.*}
    if [ "$latency" -gt "$high_latency_threshold" ]; then
        echo "High Network Latency detected: $latency ms" >> "$ping_file"
    fi
else
    echo "Latency data not available" >> "$ping_file"
fi

echo "Timestamp: $(date)" > "$traceroute_file"
echo "Network Route to Google DNS:" >> "$traceroute_file"
traceroute 8.8.8.8 >> "$traceroute_file"

echo "Timestamp: $(date)" > "$netstat_file"
echo "Active Network Connections:" >> "$netstat_file"
netstat -p tcp -n >> "$netstat_file"

echo "Timestamp: $(date)" > "$lsof_file"
echo "Open Files and Associated Processes:" >> "$lsof_file"
lsof -nP | head -10 >> "$lsof_file"

echo "Timestamp: $(date)" > "$vmstat_file"
echo "Virtual Memory Statistics:" >> "$vmstat_file"
vm_stat -c 5 1 >> "$vmstat_file"
