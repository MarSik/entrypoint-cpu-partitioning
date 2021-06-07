#!/bin/bash
function join { local IFS=","; echo "$*"; }

echo "Initial"
export LANG=C
CORES_ALL=$(taskset -pc $$ | cut -d' ' -f6)

# Generate list of all available CPUs
CORES_ALL_SIMPLE=()
IFS=',' read -ra cores <<< "$CORES_ALL"
for s in ${cores[@]}; do
  IFS='-' read -ra range <<< "$s"
  if [ "x${range[1]}" = "x" ]; then
    CORES_ALL_SIMPLE+=(${range[0]})
  else
    for c in $(seq ${range[0]} ${range[1]}); do
      CORES_ALL_SIMPLE+=($c)
    done
  fi
done

echo "All cpus: ${CORES_ALL_SIMPLE[@]}"

# Detect housekeeping siblings
CORES_HK_SIMPLE=()
IFS=',' read -ra cores < "/sys/bus/cpu/devices/cpu${CORES_ALL_SIMPLE[0]}/topology/thread_siblings_list"
for s in ${cores[@]}; do
  IFS='-' read -ra range <<< "$s"
  if [ "x${range[1]}" = "x" ]; then
    CORES_HK_SIMPLE+=(${range[0]})
  else
    for c in $(seq ${range[0]} ${range[1]}); do
      CORES_HK_SIMPLE+=($c)
    done
  fi
done

# Remove housekeeping from isolated
CORES_ISOL_SIMPLE=${CORES_ALL_SIMPLE[@]}
for c in ${CORES_HK_SIMPLE[@]}; do
  CORES_ISOL_SIMPLE=${CORES_ISOL_SIMPLE[@]/$c}
done

CORES_ISOL=$(join ${CORES_ISOL_SIMPLE[@]})
CORES_HK=$(join ${CORES_HK_SIMPLE[@]})

export CORES_HK CORES_ISOL
env | grep CORES_

exec taskset -c $CORES_HK ./stage2.sh "$@"

