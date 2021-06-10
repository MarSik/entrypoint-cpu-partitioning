#/bin/sh
echo
echo "Stage 2"
taskset -pc $$
taskset -c $CORES_ISOL ./process.sh "isolated"
./process.sh "hk"
"$@"
