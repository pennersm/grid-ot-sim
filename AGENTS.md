# Grid OT Simulator — Codex Agent Contract

## Mission
Build a reproducible, technically credible electric distribution-grid simulation for Palo Alto Networks OT security demonstrations. Real DNP3 and later MQTT/TLS traffic must cross a real PA-440, be recognized by PAN-OS App-ID, and expose changing electrical measurements and control operations. The goal is a maintainable lab, not a packet generator.

## Verified baseline (preserve)
- **MASTER**: `192.168.1.133`, Ubuntu, DNP3 master; Python 3.10.16 virtual environment `/opt/grid-sim/.venv`; `dnp3-python` demo communicates successfully.
- **OUTSTATION**: `172.18.0.4`, Ubuntu, DNP3 outstation; same Python 3.10.16 venv and `dnp3-python`; `pandapower` installed and a simple four-bus load-flow calculation succeeds.
- DNP3 native TCP port **20000**, initiated normally by MASTER toward OUTSTATION. PAN-OS PA-440 between them has been observed identifying **clean DNP3 App-ID**.
- Development workstation: Ubuntu GUI VM with Cursor and Codex CLI. SSH client alias **`grid-outstat`** uses `monitor@172.18.0.4` through `root@192.168.1.5` (Samson Proxmox host); MASTER access is direct or as already configured on workstation. **Inspect actual SSH config**; do not assume `grid-master` alias exists.
- Samson has host-only `vmbr18` access to `172.18.0.0/24` (previously tested with `172.18.0.254/24`). Confirm present state rather than treating temporary IP configuration as persistent.
- OUTSTATION stays **single-homed**. Do not change routing, interfaces, Proxmox bridges, firewall policies, NAT, SSH daemon configuration, or introduce source policy routing/IP forwarding without explicit authorization.
- `gridsim` is an interactive shell helper for activating venv; noninteractive scripts should invoke `/opt/grid-sim/.venv/bin/python` explicitly.

## Working method and safety
1. **Repository is the source of truth.** Edit code locally in the Git working tree; deploy to VMs by explicit scripts over SSH. No ad-hoc code drift on VMs.
2. Start with **read-only discovery**: hostname, OS, virtualenv/package versions, DNP3 CLI `--help`, Python API introspection, existing processes, listening sockets, and currently deployed code. Do not alter running services in the first task.
3. Never fabricate `dnp3-python` APIs. Inspect installed package/examples and implement against verified calls. If the VOLTTRON-based wrapper cannot support dynamic point updates/control, document the limitation and propose options before replacing it.
4. Preserve the working master/outstation demo until a replacement passes end-to-end tests. Use an alternate port or scheduled cutover for experiments to avoid interrupting the baseline.
5. Prefer minimal dependencies, Python 3.10 compatibility on target VMs, typed modules, structured logs, explicit configuration, and tests. Never use real operational utility infrastructure.
6. **No credentials in Git, AGENTS.md, CLI logs or chat.** Use environment variables or a gitignored local `.env`/secrets file; redact API keys and authentication headers in outputs. Use read-only credentials for discovery when possible.
7. Before remote commands that change packages, processes, services, routes, networking, firewall, or persistent files: show the exact plan and request approval. Codex sandbox approval is not a substitute for explicit user intent.
8. Avoid sudo by default. For service deployment use scoped privileges; do not require unrestricted passwordless sudo as a project assumption.
9. Display commands/actions and meaningful errors. Provide rollback steps for deployment changes. Don't silently overwrite files.
10. Keep documentation, architecture decisions, protocol point maps, and acceptance tests under version control.

## Logical architecture
```text
Ubuntu development workstation (Cursor + Codex + Git)
       | SSH/scp/rsync via Samson where necessary
       +---- MASTER 192.168.1.133 (SCADA, DNP3 master)
       +---- OUTSTATION 172.18.0.4 (DNP3 outstation + pandapower)

MASTER -- native DNP3 TCP/20000 --> PA-440 --> OUTSTATION
                                          electrical model
```
- **Electrical engine**: pandapower network and deterministic step-based power-flow solver.
- **Scenario controller**: changes load/generation and operating states, faults and switching events, optional reproducible random noise.
- **Protocol adapters**: DNP3 outstation first; MQTT/TLS later; do not couple engine to transport.
- **SCADA master**: polls, displays and logs points; later issues safe control commands.
- **Visualization**: future topology/control dashboard, kept separate from protocol and solver.

## Target grid model (incremental)
Represent a plausible distribution network containing two city blocks, two rural areas, a factory, an industrial park and a power plant. Include source/substation, feeders, transformer(s), line segments, controllable breakers/reclosers, capacitor banks and voltage regulation as model sophistication grows. Support configurable P (MW), Q (MVAr), voltages, currents, line loading, breaker state, power-flow results, slow/smooth time variation, deterministic random seed and repeatable event scenarios. Start with a tiny solvable network and extend iteratively; distinguish real power-flow effects from simplified/illustrative fault behavior.

## DNP3 semantics and point contract
- Native DNP3 over TCP, not HTTP wrapping, replayed PCAPs or fabricated payloads.
- MASTER is central SCADA; OUTSTATION is field device. Master initiates TCP and polls/controls; outstation returns measurements/events.
- Stable indexed **analog inputs**: voltage, current, P, Q, loading. Stable indexed **binary inputs**: breaker/recloser status. Later controls should map to explicitly modeled operations and support safe rejection/validation.
- Create a versioned `docs/dnp3-points.md` mapping index, type, units, scale, quality, source in pandapower, update interval and any command semantics. Do not claim a point is operational until read across firewall by MASTER.
- Verify DNP3 object variation, event/quality support, class scans and command APIs against installed library rather than assuming.
- Bind production OUTSTATION listener to OT interface `172.18.0.4` rather than `0.0.0.0` if supported; confirm CLI/API before changing working demo.
- Confirm PAN-OS App-ID remains `dnp3` after integration; preserve evidence/logs of acceptance test.

## MQTT/TLS phase (not milestone 1)
Use actual MQTT client/broker traffic (e.g. Paho and Mosquitto) with TLS and certificate validation; ensure traffic crosses firewall as intended. Do not replace DNP3 or use HTTP as a stand-in. Document topic tree, QoS, certificate lifecycle and telemetry sources when this phase begins.

## Suggested repository layout
```
grid-ot-sim/
  AGENTS.md
  README.md
  .gitignore
  pyproject.toml
  configs/
  docs/
    architecture.md
    dnp3-points.md
    deployment.md
  src/grid_sim/
    electrical/
    scenarios/
    protocols/dnp3/
    protocols/mqtt/
  scripts/
    discover.sh
    deploy-outstat.sh
    deploy-master.sh
  tests/
```
This is a proposal, not a requirement to scaffold everything before writing the first feature.

## Milestone 1: live electrical measurements over DNP3
1. Read-only inventory of both VMs and installed DNP3 API.
2. Minimal pandapower network with deterministic load changes; validate `runpp()` convergence and measurements.
3. Publish at least one changing bus voltage and one changing line/load metric as DNP3 analog inputs on OUTSTATION.
4. Read these from MASTER over the existing firewall, with documented point indices and units.
5. Verify App-ID remains `dnp3` and demonstrate a load change alters values seen by MASTER.
6. Add tests, logging, configuration and a reversible deployment procedure.

## GitHub repository
- Use the user's **private GitHub repository** once authenticated/authorized. Do not assume repository name or create/push remote content without approval.
- Suggested name: `grid-ot-sim` (private). Local checkout should be within the user's chosen Codex project directory; confirm the exact path before creating anything.
- Do not commit `.env`, API keys, SSH private keys, credentials, runtime logs, captures containing sensitive data, virtualenvs or machine-specific secrets.
- Suggested first commit: `docs: establish grid simulator contract`.

## First Codex instruction
Inspect the existing working tree and `AGENTS.md`, then perform **read-only** inspection of MASTER and OUTSTATION. Report verified Python/OS/package versions, actual SSH paths, current DNP3 demo commands and APIs, service/process state, and the smallest credible plan to publish pandapower analog measurements through the existing DNP3 library. **Do not change remote systems or deploy anything until the user approves the plan.**
