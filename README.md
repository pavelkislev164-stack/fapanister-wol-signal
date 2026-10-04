# Fapanister WoL Signal

Minimal public control-plane repository for the production Fapanister Wake-on-LAN path.

## Production architecture

ChatGPT / GitHub connector
-> permanent GitHub issue `Fapanister Wake Control`
-> GitHub Actions workflow `.github/workflows/wake-control.yml`
-> `wake-trigger.txt`
-> Cudy WR3000S v1 / OpenWrt 25.12.5
-> `/usr/bin/fapanister-wol-poll`
-> `/usr/bin/fapanister-wake`
-> broadcast Magic Packet on `br-lan`
-> Fapanister

No VPS, Vercel or Xiaomi is part of the production WoL path.

## Control issue

Permanent issue:
`Fapanister Wake Control`

Its body is the only operator-facing command input.

Idle:
`none|NONE`

Wake request:
`UNIQUE_ID|WAKE`

The GitHub Action validates the command and synchronizes it into `wake-trigger.txt`.
The Cudy poller has replay protection through the last processed unique ID.

Normal use does not require the user to edit GitHub files manually.

## Router behavior

Cudy polls every 2 minutes.
For a new WAKE ID it sends three broadcast Magic Packets through `br-lan`.
The design does not depend on a specific physical LAN port.

## Security

This repository is public and must never contain passwords, API tokens, cookies, SSH private keys, VPN/router credentials or private configuration.

Write access to the control issue is wake authority for Fapanister.
