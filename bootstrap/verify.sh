#!/usr/bin/env bash
set -Eeuo pipefail
role="${1:-}"
[[ "$role" == master || "$role" == outstat ]] || { echo 'Usage: bash bootstrap/verify.sh master|outstat' >&2; exit 2; }
PY=/opt/grid-sim/.venv/bin/python
"$PY" --version
"$PY" -m pip show dnp3-python
/opt/grid-sim/.venv/bin/dnp3demo --help
if [[ "$role" == outstat ]]; then
  "$PY" -c 'import pandapower as pp; n=pp.networks.simple_four_bus_system(); pp.runpp(n); print("bus voltages:", n.res_bus.vm_pu.to_list())'
fi
printf '\nLibrary verification done. Actual master/outstation connectivity and PAN-OS App-ID require separate end-to-end testing.\n'
