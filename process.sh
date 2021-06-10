#!/bin/bash
echo
echo "P" $1
taskset -pc $$
