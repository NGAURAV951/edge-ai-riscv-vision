$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path build | Out-Null

gcc -std=c99 -Wall -Wextra -Werror -Ifirmware firmware/monitor.c tests/test_monitor.c -lm -o build/test_monitor.exe
if ($LASTEXITCODE -ne 0) { throw 'C test build failed.' }
.\build\test_monitor.exe
if ($LASTEXITCODE -ne 0) { throw 'C tests failed.' }

gcc -std=c99 -Wall -Wextra -Werror -Ifirmware firmware/monitor.c firmware/demo.c -lm -o build/monitor_demo.exe
if ($LASTEXITCODE -ne 0) { throw 'C demo build failed.' }
.\build\monitor_demo.exe
if ($LASTEXITCODE -ne 0) { throw 'C demo failed.' }

if (Get-Command py -ErrorAction SilentlyContinue) {
    py tools/analyze_log.py data/sample_telemetry.csv
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    python tools/analyze_log.py data/sample_telemetry.csv
} else {
    Write-Warning 'Python not found; skipped CSV analyser.'
}