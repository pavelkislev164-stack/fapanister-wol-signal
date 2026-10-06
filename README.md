# Fapanister WoL Signal / Recovery v2 Control Plane

Canonical state: 2026-10-06.

## Production WoL

This repository is NOT the production Wake-on-LAN transport.

Production WoL:
Nothing Phone HTTP Shortcut -> private external signal -> Cudy/OpenWrt -> fapanister-wol-poll -> fapanister-wake -> Fapanister

The production WoL path is certified and must remain separate from Recovery v2.

## Recovery v2

This repository now contains the GitHub-side Recovery v2 control plane.

Relevant files:
- recovery-trigger.txt
- RECOVERY_V2.md
- .github/workflows/recovery-control.yml

Strict command allowlist:
STATUS
RECOVER_DC
RECOVER_LIRA
RECOVER_MESH
RECOVER_RUSTDESK
RECOVER_ALL
NONE

No arbitrary shell. No secrets in this repository. Workflow control is restricted to the authorized repository owner.

STATUS end-to-end has been tested successfully. Full independent Cudy/OpenWrt -> Windows recovery and RECOVER_* certification are still in progress.

## LiraBrowser note

LiraBrowser is NOT a ChatGPT/MCP connector.

Canonical browser path:
ChatGPT -> Desktop Commander -> Node/Playwright -> LiraBrowser Chrome -> CDP 127.0.0.1:9333

Agents must not wait for a separate "Lira Browser" tool. If Desktop Commander is available, use it to run Playwright on Fapanister and attach with chromium.connectOverCDP('http://127.0.0.1:9333').

Browser policy:
- LiraBrowser/Chrome: production
- Edge: reserve only
- Opera: retired
- Firefox: retired

Never commit browser profiles, cookies, sessions, passwords, SSH private keys, tokens or router credentials.
