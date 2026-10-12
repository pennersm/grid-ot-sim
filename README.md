# Grid OT simulator

First goal: reproduce the existing **native DNP3** baseline, then publish live pandapower measurements. Read [AGENTS.md](AGENTS.md) before development.

## Verified lab (2026-10)
- MASTER: `192.168.1.133` (DNP3 master)
- OUTSTATION: `172.18.0.4` (DNP3 outstation + pandapower)
- TCP/20000 through PA-440, recognized as DNP3 by PAN-OS.
- Existing runtime: Ubuntu 24.04, Python 3.10.16 built with pyenv, `/opt/grid-sim/.venv`, `dnp3-python` (VOLTTRON-based wrapper). Outstation also has pandapower.

## Reproduce, don't replace
1. On **both** VMs, run `bash bootstrap/inventory.sh` and save outputs **locally outside Git**; capture `pip freeze` and installed package provenance before pinning dependencies.
2. On a **fresh test VM**, run `bash bootstrap/install.sh master` or `bash bootstrap/install.sh outstat`. This creates `/opt/grid-sim/.venv` but does not start a daemon or change networking.
3. Verify `bash bootstrap/verify.sh master` / `outstat`.
4. Inspect `dnp3demo master --help` and `dnp3demo outstation --help`; preserve the actual known-working flags and DNP3 library APIs before writing wrappers.

**Compatibility:** Ubuntu 24.04 tested in the original lab; Ubuntu 22.04 and Debian 12/13 are targets to validate, not yet verified. Python **3.10.16** is the baseline even when the OS default is newer. The `dnp3-python` native dependencies may not build or install on every distribution/architecture. Use a test VM, not the working pair, for rebuild validation.

**No protocol code has been copied from the existing VMs yet.** The working baseline is the installed `dnp3demo` package; `protocols/dnp3/{master,outstation}` are placeholders for the future application code.

## Git
Use a **private** GitHub repository and ordinary `git` over HTTPS with a fine-grained token, or SSH. Never put the token in a remote URL, shell history, Git files or agent instructions. Use Git Credential Manager or a secure credential helper. GitHub account 2FA does not prevent token-based HTTPS Git operations.
