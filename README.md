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

Implemented router dispatch actions (verified against router/fapanister-recovery-v2-poll):
STATUS
RECOVER_DC
RECOVER_LIRA
NONE

RECOVER_MESH, RECOVER_RUSTDESK and RECOVER_ALL are reserved names accepted by the historical GitHub workflow, but the current router poller does not dispatch them. Do not send them expecting recovery.

A successful GitHub write or a running Windows DC process does not prove hosted DC connectivity. Require a fresh returned command result. See RECOVERY_V2.md and private fapanister-wol-bridge/DC-INCIDENT-2026-10-08.md.

No arbitrary shell. No secrets in this repository. Workflow control is restricted to the authorized repository owner.

## Certified status

Certified 2026-10-07:
- STATUS
- RECOVER_DC
- RECOVER_LIRA

Independent path:
ChatGPT -> GitHub recovery-trigger.txt -> Cudy/OpenWrt Recovery v2 poller -> HMAC-SHA256 authenticated LAN request -> Windows Recovery Agent -> requested recovery action.

Windows Recovery Agent:
- binds only to 192.168.1.169:8765
- HMAC-SHA256 authentication
- timestamp freshness + nonce replay protection
- rejects unsigned traffic

Cudy Recovery v2:
- separate from production WoL poller
- GitHub Contents API used instead of raw.githubusercontent.com
- dedicated procd service: fapanister-recovery-v2
- HMAC helper uses ucode-mod-digest
- no recovery secret is stored in GitHub

RECOVER_DC controlled failure was verified with the normal DC startup script temporarily unavailable.

RECOVER_LIRA controlled failure was verified with the normal LiraBrowser startup script temporarily unavailable. LiraBrowser returned on 127.0.0.1:9333 using the same persistent profile, and the authenticated Tilda /projects/ session survived.

See RECOVERY_V2.md for certification details.

## Administrative route is separate

Router administration is NOT done through the Recovery v2 GitHub trigger.

The separate local admin route is:

Desktop Commander -> Windows/Node.js -> ssh2 -> Cudy/OpenWrt

It is documented in the fapanister-wol-bridge repository as CUDY-ADMIN.md.

This separation is intentional:
- Recovery v2 keeps a strict allowlist and no arbitrary shell.
- The admin route is local-only from Fapanister and uses the existing LAN-only SSH service.

## LiraBrowser note

LiraBrowser is NOT a ChatGPT/MCP connector.

Canonical browser path:
ChatGPT -> Desktop Commander -> Node/Playwright -> LiraBrowser Chrome -> CDP 127.0.0.1:9333

Browser policy:
- LiraBrowser/Chrome: production
- Edge: reserve only
- Opera: retired
- Firefox: retired

Never commit browser profiles, cookies, sessions, passwords, SSH private keys, tokens, router credentials or Recovery v2 secrets.
