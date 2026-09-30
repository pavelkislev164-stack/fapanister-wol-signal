# Fapanister WoL Signal

Signal-only repository for the production Fapanister Wake-on-LAN bridge.

## Purpose

This repository is polled by the VPS bridge at /opt/fapanister-wol/bridge.sh.

The main code, recovery scripts, browser agent, and documentation live in:
pavelkislev164-stack/fapanister-wol-bridge

## wake-trigger.txt

Idle state:

none|NONE

Wake request format:

UNIQUE_ID|WAKE

Always use a fresh unique ID for a new wake request.
After a successful or abandoned wake attempt, reset the file to none|NONE.

## Security

This repository is public and must never contain:
- passwords
- API tokens
- cookies
- SSH private keys
- VPN/router credentials
- private configuration files

Write access to this repository is remote-control authority for Fapanister wake operations.
