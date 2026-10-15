#!/usr/bin/env bash
set -eu
mkdir -p build
gcc -std=c99 -Wall -Wextra -Werror -Ifirmware firmware/monitor.c tests/test_monitor.c -lm -o build/test_monitor
./build/test_monitor
gcc -std=c99 -Wall -Wextra -Werror -Ifirmware firmware/monitor.c firmware/demo.c -lm -o build/monitor_demo
./build/monitor_demo
python3 tools/analyze_log.py data/sample_telemetry.csv