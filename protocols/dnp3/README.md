# DNP3

Two roles, one protocol: `master/` (SCADA) and `outstation/` (field). The working implementation today is **the installed `dnp3demo` executable**, not checked-in custom source. Master connects to outstation TCP/20000 across PA-440. Do not claim this repository recreates the working service until an isolated rebuild and an end-to-end test pass. Capture actual flags via `dnp3demo master --help` / `dnp3demo outstation --help`.

Future: stable analog/binary point mapping in `docs/dnp3-points.md`; dynamic data from `simulation/` via adapter. MQTT belongs alongside DNP3 under `protocols/` only when needed.
