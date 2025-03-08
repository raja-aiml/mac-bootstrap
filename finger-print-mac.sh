#!/usr/bin/env sh

echo "🖥️  Mac System Information"
echo "----------------------------------"

# Get Mac Model
MAC_MODEL=$(sysctl -n hw.model)
echo "🖥️  Mac Model:         $MAC_MODEL"

# Get RAM Size in GB
RAM_SIZE=$(sysctl -n hw.memsize)
RAM_GB=$((RAM_SIZE / 1024 / 1024 / 1024))
echo "💾 RAM:               ${RAM_GB} GB"

# Get CPU Information
CPU_MODEL=$(sysctl -n machdep.cpu.brand_string)
CPU_CORES=$(sysctl -n hw.ncpu)
echo "⚙️  CPU Cores:         $CPU_CORES"

# Get GPU Information
GPU_CORES=$(system_profiler SPDisplaysDataType | awk -F": " '/Total Number of Cores/ {print $2}')
echo "🎲 GPU Cores:         ${GPU_CORES:-N/A}"  # Fallback to N/A if no cores are found

# Get Disk Space Information
DISK_TOTAL=$(df -H / | awk 'NR==2 {print $2}')  # Total disk space
DISK_USED=$(df -H / | awk 'NR==2 {print $3}')   # Used disk space
DISK_FREE=$(df -H / | awk 'NR==2 {print $4}')   # Available disk space
echo "🛠️  Disk Space:"
echo "     📦 Total:        $DISK_TOTAL"
echo "     📊 Used:         $DISK_USED"
echo "     📉 Free:         $DISK_FREE"