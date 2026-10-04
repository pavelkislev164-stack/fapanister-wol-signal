# Fapanister WoL Signal — RETIRED

This repository is retained only as historical evidence of an earlier Wake-on-LAN control plane.

Retired on: 2026-10-04.

## Current production path

The active WoL path no longer uses GitHub Actions or `wake-trigger.txt`.

Current architecture:

Android HTTP Shortcut
-> private external signal channel
-> Cudy WR3000S v1 / OpenWrt 25.12.5
-> `/usr/bin/fapanister-wol-poll`
-> `/usr/bin/fapanister-wake`
-> broadcast Magic Packet on `br-lan`
-> Fapanister

The current control-channel identifier is intentionally not stored in this public repository.

## Status

- GitHub workflow: removed.
- Trigger file: removed.
- Control issue: closed / retired.
- No active router polls this repository.

Do not restore this repository as a production WoL path unless the architecture is deliberately redesigned and recertified.
