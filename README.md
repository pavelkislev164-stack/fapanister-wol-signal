# Fapanister WoL Signal / Recovery v2 Control Plane

Canonical state: 2026-10-07.

## Production WoL

This repository is NOT the production Wake-on-LAN transport.

Production WoL:
Nothing Phone HTTP Shortcut -> private external signal -> Cudy/OpenWrt -> fapanister-wol-poll -> fapanister-wake -> Fapanister

The production WoL path is certified and must remain separate from Recovery v2.

## Recovery v2

This repository contains the GitHub-side Recovery v2 control plane.

Relevant files:
- recovery-trigger.txt
- RECOVERY_V2.md
- .github/workflows/recovery-control.yml
- router/fapanister-recovery-v2-poll
- router/fapanister-hmac.uc
- router/fapanister-recovery-v2-init
- router/fapanister-recovery-v2-poll
- router/fapanister-hmac.uc
- router/fapanister-recovery-v2-init

Strict command allowlist:
STATUS
RECOVER_DC
RECOVER_LIRA
RECOVER_MESH
RECOVER_RUSTDESK
RECOVER_ALL
NONE

No arbitrary shell. No secrets in this repository. Workflow control is restricted to the authorized repository owner.

## Certified status

Independent STATUS path certified 2026-10-07:

ChatGPT -> GitHub recovery-trigger.txt -> Cudy/OpenWrt Recovery v2 poller -> HMAC-SHA256 authenticated LAN request -> Windows Recovery Agent -> STATUS result

Observed Windows result:
DC active; Lira listening; Mesh running; RustDesk running.

Windows Recovery Agent:
- binds only to 192.168.1.169:8765
- accepts authenticated requests with timestamp + nonce + HMAC-SHA256
- rejects unsigned requests
- replay/freshness protection enabled

Cudy Recovery v2:
- separate from production WoL poller
- GitHub Contents API used instead of raw.githubusercontent.com because the raw endpoint returned stale content during certification
- dedicated procd service: fapanister-recovery-v2
- HMAC helper uses ucode-mod-digest
- no recovery secret is stored in GitHub

GitHub issue workflow -> recovery-trigger.txt had already been validated separately. The 2026-10-07 independent Cudy -> Windows certification used a fresh GitHub trigger and was confirmed in the Windows LAN agent log from source 192.168.1.1.

Next certification target: RECOVER_DC. Do not deliberately kill Desktop Commander until the RECOVER_DC implementation is installed and the independent route is ready to restore it.

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

Never commit browser profiles, cookies, sessions, passwords, SSH private keys, tokens, router credentials or Recovery v2 secrets.
