#!/usr/bin/env bash
set -u
printf '===== OS / PYTHON =====\n'; hostname; cat /etc/os-release; uname -m
/opt/grid-sim/.venv/bin/python --version 2>&1
printf '\n===== PIP FREEZE (save separately, review before committing) =====\n'
/opt/grid-sim/.venv/bin/python -m pip freeze 2>&1
printf '\n===== DNP3 CLI =====\n'
/opt/grid-sim/.venv/bin/dnp3demo --help 2>&1
printf '\n===== LISTENERS =====\n'
ss -lntp 2>&1 | grep -E '(^State|:20000)' || true
printf '\n===== DNP3 PROCESS =====\n'
ps -eo pid,args | grep '[d]np3' || true
