#!/bin/bash
#
# CPU Temperature script - supports multiple thermal sources
#

PRE=$(dirname $(realpath $0))"/../"

source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("TEMPERATURE" "CELSIUS" "ALL")

ARG_TEMPERATURE=false
ARG_TEMPERATURE_CELSIUS=false
ARG_ALL=false

TEMPERATURE_SHORT_ARG="-t"
TEMPERATURE_ARG="--temperature"
TEMPERATURE_VAL=false

CELSIUS_SHORT_ARG="-T"
CELSIUS_ARG="--celsius"
CELSIUS_VAL=false

ALL_SHORT_ARG="-a"
ALL_ARG="--all"
ALL_VAL=false

source $PRE'src/pca.sh'

print_thermal_zones() {
	local found=0
	for zone in /sys/class/thermal/thermal_zone*; do
		if [[ -f "$zone/temp" ]]; then
			local temp=$(cat "$zone/temp" 2>/dev/null)
			local type=$(cat "$zone/type" 2>/dev/null)
			if [[ -n "$temp" ]]; then
				found=1
				local temp_c=$((temp/1000))
				echo "Zone: $(basename $zone) | Type: $type | Temp: ${temp_c}°C"
			fi
		fi
	done
	return $found
}

print_hwmon_temps() {
	local found=0
	for h in /sys/class/hwmon/hwmon*; do
		local name=$(cat "$h/name" 2>/dev/null)
		for t in "$h"/temp*_input; do
			if [[ -f "$t" ]]; then
				local temp=$(cat "$t" 2>/dev/null)
				local label="${t%_input}_label"
				local label_val=""
				if [[ -f "$label" ]]; then
					label_val=$(cat "$label" 2>/dev/null)
				fi
				if [[ -n "$temp" && "$temp" != "0" ]]; then
					found=1
					local temp_c=$((temp/1000))
					echo "Hwmon: $(basename $h) ($name) | ${label_val:-Sensor} | Temp: ${temp_c}°C"
				fi
			fi
		done
	done
	return $found
}

print_cooling_devices() {
	echo "=== Cooling Devices ==="
	for c in /sys/class/thermal/cooling_device*; do
		if [[ -f "$c/cur_state" ]]; then
			local state=$(cat "$c/cur_state" 2>/dev/null)
			local max=$(cat "$c/max_state" 2>/dev/null)
			local type=$(cat "$c/type" 2>/dev/null)
			echo "Cooling: $(basename $c) | Type: $type | State: ${state}/${max:-?}"
		fi
	done
}

print_rapl() {
	echo "=== RAPL Power Zones ==="
	for rapl in /sys/class/powercap/*; do
		if [[ -f "$rapl/energy_uj" ]]; then
			local name=$(basename "$rapl")
			echo "Powercap: $name"
		fi
	done
}

check_amd_ryzen() {
	if [[ -f "/sys/class/hwmon/hwmon3/name" ]]; then
		local name=$(cat /sys/class/hwmon/hwmon3/name 2>/dev/null)
		if [[ "$name" == "k10temp" ]]; then
			echo "=== AMD Ryzen Sensors ==="
			for t in /sys/class/hwmon/hwmon3/temp*_input; do
				local temp=$(cat "$t" 2>/dev/null)
				local label="${t%_input}_label"
				local label_val=""
				[[ -f "$label" ]] && label_val=$(cat "$label")
				if [[ -n "$temp" && "$temp" != "0" ]]; then
					local temp_c=$((temp/1000))
					echo "AMD: ${label_val:-$(basename $t)} | Temp: ${temp_c}°C"
				fi
			done
		fi
	fi
}

check_nvme() {
	echo "=== NVMe Temps ==="
	for h in /sys/class/hwmon/hwmon*; do
		local name=$(cat "$h/name" 2>/dev/null)
		if [[ "$name" == "nvme" ]]; then
			local temp=$(cat "$h/temp1_input" 2>/dev/null)
			if [[ -n "$temp" && "$temp" != "0" ]]; then
				local temp_c=$((temp/1000))
				echo "NVMe: $(basename $h) | Temp: ${temp_c}°C"
			fi
		fi
	done
}

check_gpu() {
	echo "=== GPU Temps ==="
	for h in /sys/class/hwmon/hwmon*; do
		local name=$(cat "$h/name" 2>/dev/null)
		if [[ "$name" == "amdgpu" ]]; then
			local temp=$(cat "$h/temp1_input" 2>/dev/null)
			if [[ -n "$temp" && "$temp" != "0" ]]; then
				local temp_c=$((temp/1000))
				echo "GPU: $(basename $h) | Temp: ${temp_c}°C"
			fi
		fi
	done
}

main() {
	if [[ "$ARG_ALL" == "true" ]]; then
		check_amd_ryzen
		print_hwmon_temps
		print_cooling_devices
		check_nvme
		check_gpu
		print_rapl
		return 0
	fi

	local total=0
	local count=0

	for h in /sys/class/hwmon/hwmon*; do
		local name=$(cat "$h/name" 2>/dev/null)
		for t in "$h"/temp1_input; do
			if [[ -f "$t" ]]; then
				local temp=$(cat "$t" 2>/dev/null)
				if [[ -n "$temp" && "$temp" != "0" && "$temp" -lt 150000 ]]; then
					total=$((total + temp))
					count=$((count + 1))
				fi
			fi
		done
	done

	if [[ $count -gt 0 ]]; then
		local avg=$((total / count / 1000))
		echo "CPU Temp: ${avg}°C"
	else
		echo "No temperature sensors found. Try -a flag for full report."
		exit 1
	fi
}

main