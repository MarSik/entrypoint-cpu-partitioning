#!/bin/bash
echo "P" $1
taskset -pc $$
