#!/usr/bin/env bash
set -Eeuo pipefail
role="${1:-}"
if [[ "$role" != master && "$role" != outstat ]]; then echo "Usage: bash bootstrap/install.sh master|outstat" >&2; exit 2; fi
if [[ "$(id -u)" != 0 ]]; then echo "Run as root on a fresh target VM" >&2; exit 1; fi
. /etc/os-release
echo "OS: $PRETTY_NAME; role: $role"
if [[ "$ID" != ubuntu && "$ID" != debian ]]; then echo "Untested OS: $ID" >&2; exit 1; fi
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y build-essential make gcc g++ git curl ca-certificates pkg-config \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev \
  liblzma-dev tk-dev xz-utils uuid-dev
export PYENV_ROOT=/opt/grid-sim/pyenv
mkdir -p /opt/grid-sim
if [[ ! -x "$PYENV_ROOT/bin/pyenv" ]]; then
  git clone --depth 1 https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
fi
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
if [[ ! -x "$PYENV_ROOT/versions/3.10.16/bin/python3" ]]; then pyenv install 3.10.16; fi
if [[ ! -x /opt/grid-sim/.venv/bin/python ]]; then "$PYENV_ROOT/versions/3.10.16/bin/python3" -m venv /opt/grid-sim/.venv; fi
PY=/opt/grid-sim/.venv/bin/python
"$PY" -m pip install --upgrade pip
"$PY" -m pip install -r "$(dirname "$0")/../protocols/dnp3/requirements.txt"
if [[ "$role" == outstat ]]; then "$PY" -m pip install -r "$(dirname "$0")/../simulation/requirements.txt"; fi
echo "Installed environment at /opt/grid-sim/.venv. No network/service configuration changed."
